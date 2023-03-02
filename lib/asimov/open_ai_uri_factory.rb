require_relative "base_uri_factory"

module Asimov
  ##
  # Configures the URI used for the request
  #
  # Not intended for client use.
  ##
  class OpenAIUriFactory < BaseUriFactory
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
      @api_version = api_version
    end
  end
end
