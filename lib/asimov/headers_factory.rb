module Asimov
  class HeadersFactory
    NULL_ORGANIZATION_ID = Object.new.freeze

    attr_reader :access_token, :organization_id

    def initialize(access_token, organization_id)
      @access_token = access_token || Asimov.configuration.access_token
      initialize_organization_id(organization_id)

      raise Asimov::MissingAccessTokenError unless @access_token
    end

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
      @auth_headers ||= { "Authorization" => bearer_header(access_token) }
    end

    def bearer_header(access_token)
      "Bearer #{access_token}"
    end
  end
end
