module Asimov
  ##
  # Configures the URI used for the request, assuming an Azure endpoint.
  #
  # Not intended for client use.
  ##
  class AzureUriFactory
    def resource_singular_uri(resource)
      absolute_path("/#{Array(resource).join('/')}")
    end

    def resource_class_uri(resource)
      absolute_path("/#{Array(resource).join('/')}")
    end

    def resource_instance_uri(resource, id)
      absolute_path("/#{resource}/#{CGI.escape(id)}")
    end

    private

    def absolute_path(path)
      "#{openai_api_base}#{path}"
    end

    def initialize_api_version(api_version)
      @api_version = api_version || Asimov.configuration.api_version(api_type)
      raise Asimov::MissingApiVersionError unless @api_version
    end
  end
end
