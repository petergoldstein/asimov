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

    ##
    # Null object used to allow nil override of a default project_id.
    ##
    NULL_PROJECT_ID = Object.new.freeze

    attr_reader :api_key, :organization_id, :project_id

    def initialize(api_key, organization_id, project_id)
      @api_key = api_key || Asimov.configuration.api_key
      initialize_organization_id(organization_id)
      initialize_project_id(project_id)

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

    def initialize_project_id(project_id)
      @project_id = if project_id == NULL_PROJECT_ID
                      Asimov.configuration.project_id
                    else
                      project_id
                    end
    end

    def openai_headers
      @openai_headers ||= begin
        h = auth_headers
        h = h.merge({ "OpenAI-Organization" => organization_id }) unless organization_id.nil?
        h = h.merge({ "OpenAI-Project" => project_id }) unless project_id.nil?
        h
      end
    end

    def auth_headers
      @auth_headers ||= { "Authorization" => bearer_header(api_key) }
    end

    def bearer_header(api_key)
      "Bearer #{api_key}"
    end
  end
end
