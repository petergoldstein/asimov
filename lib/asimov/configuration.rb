require_relative "utils/request_options_validator"

module Asimov
  ##
  # Application-wide configuration for the Asimov library. Should be
  # configured once using the Asimov.configure method on application
  # startup.
  ##
  class Configuration
    attr_accessor :api_key, :organization_id

    attr_reader :request_options, :openai_api_base, :api_type
    attr_writer :api_version

    DEFAULT_OPENAI_BASE_URI = "https://api.openai.com/v1".freeze

    ##
    # Initializes the Configuration object and resets it to default values.
    ##
    def initialize
      reset
    end

    ##
    # Reset the configuration to default values.  Mostly used for testing.
    ##
    def reset
      @api_type = ApiType::DEFAULT
      @api_version = nil
      @api_key = nil
      @organization_id = nil
      @request_options = {}
      @openai_api_base = DEFAULT_OPENAI_BASE_URI
    end

    def api_type=(val)
      @api_type = if val.nil?
                    ApiType::DEFAULT
                  else
                    ApiType.normalize(val)
                  end

      raise Asimov::UnknownApiTypeError unless @api_type
    end

    def api_version(client_api_type = nil)
      # Return explicitly specifed value if there is one
      return @api_version unless @api_version.nil?

      api_type_for_version = client_api_type || @api_type
      return nil unless ApiType.azure?(api_type_for_version)

      ApiType::DEFAULT_AZURE_VERSION
    end

    ##
    # Sets the openai_api_base on the Configuration.  Typically not invoked
    # directly, but rather through use of `Asimov.configure`.
    ##
    def openai_api_base=(val)
      @openai_api_base = val ? HTTParty.normalize_base_uri(val) : nil
    end

    ##
    # Sets the request_options on the Configuration.  Typically not invoked
    # directly, but rather through use of `Asimov.configure`.
    ##
    def request_options=(val)
      @request_options = Utils::RequestOptionsValidator.validate(val)
    end
  end
end
