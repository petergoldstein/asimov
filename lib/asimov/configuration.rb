require_relative "utils/request_options_validator"

module Asimov
  ##
  # Application-wide configuration for the Asimov library. Should be
  # configured once using the Asimov.configure method on application
  # startup.
  ##
  class Configuration
    attr_accessor :api_key, :organization_id

    attr_reader :request_options, :base_uri

    DEFAULT_BASE_URI = "https://api.openai.com/v1".freeze

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
      @base_uri = DEFAULT_BASE_URI
    end

    ##
    # Sets the base_uri on the Configuration.  Typically not invoked
    # directly, but rather through use of `Asimov.configure`.
    ##
    def base_uri=(val)
      @base_uri = val ? HTTParty.normalize_base_uri(val) : nil
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
