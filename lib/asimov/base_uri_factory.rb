module Asimov
  ##
  # Configures the URI used for the request, assuming an Azure endpoint.
  #
  # Not intended for client use.
  ##
  class BaseUriFactory
    attr_reader :api_type, :api_version, :openai_api_base

    def initialize(api_type, api_version, openai_api_base)
      @api_type = api_type
      initialize_api_version(api_version)
      initialize_openai_api_base(openai_api_base)
    end

    private

    def initialize_openai_api_base(openai_api_base)
      @openai_api_base = openai_api_base || Asimov.configuration.openai_api_base
      if @openai_api_base
        @openai_api_base = HTTParty.normalize_base_uri(@openai_api_base)
      else
        raise Asimov::MissingBaseUriError,
              "No API Base URI was provided for this client."
      end
    end
  end
end
