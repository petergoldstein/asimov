module Asimov
  ##
  # Configures the set of HTTP headers being sent with requests to
  # the OpenAI API. These header include authentication and content-type
  # information.
  #
  # Not intended for client use.
  ##
  class HeadersFactory
    ##
    # Null object used to allow nil override of a default organization_id.
    ##
    NULL_ORGANIZATION_ID = Object.new.freeze

    attr_reader :api_type, :api_key, :organization_id

    def initialize(api_type, api_key, organization_id)
      @api_type = api_type
      @api_key = api_key || Asimov.configuration.api_key
      initialize_organization_id(organization_id)

      return if @api_key

      raise Asimov::MissingApiKeyError,
            "No OpenAI API key was provided for this client."
    end

    ##
    # Returns the headers to use for a request.
    #
    # @param content_type The Content-Type header value for the request.
    ##
    def headers(content_type = "application/json")
      {
        "Content-Type" => content_type
      }.merge(openai_headers)
    end

    private

    def initialize_organization_id(organization_id)
      @organization_id = if organization_id == NULL_ORGANIZATION_ID
                           Asimov.configuration.organization_id
                         else
                           organization_id
                         end
    end

    def openai_headers
      @openai_headers ||=
        if organization_id.nil?
          auth_headers
        else
          auth_headers.merge(
            { "OpenAI-Organization" => organization_id }
          )
        end
    end

    def auth_headers
      @auth_headers ||= ApiType.bearer_auth?(api_type) ? bearer_auth_headers : azure_auth_headers
    end

    def azure_auth_headers
      { "api-key" => api_key }
    end

    def bearer_auth_headers
      { "Authorization" => bearer_header(api_key) }
    end

    def bearer_header(api_key)
      "Bearer #{api_key}"
    end
  end
end
