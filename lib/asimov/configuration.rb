require_relative "utils/request_options_validator"

module Asimov
  ##
  # Application-wide configuration for the Asimov library. Should be
  # configured once using the Asimov.configure method on application
  # startup.
  ##
  class Configuration
    attr_accessor :api_key, :organization_id

    attr_reader :request_options, :openai_api_base

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
      @api_key = nil
      @organization_id = nil
      @request_options = {}
      @openai_api_base = DEFAULT_OPENAI_BASE_URI
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
