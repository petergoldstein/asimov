require_relative "utils/request_options_validator"

module Asimov
  ##
  # Application-wide configuration for the Asimov library. Should be
  # configured once using the Asimov.configure method on application
  # startup.
  ##
  class Configuration
    attr_accessor :api_key, :organization_id, :project_id, :logger

    attr_reader :request_options, :openai_api_base, :max_retries, :log_level

    DEFAULT_OPENAI_BASE_URI = "https://api.openai.com/v1".freeze
    VALID_LOG_LEVELS = %i[debug info warn error fatal].freeze

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
      @project_id = nil
      @request_options = {}.freeze
      @openai_api_base = DEFAULT_OPENAI_BASE_URI
      @max_retries = 0
      @logger = nil
      @log_level = :info
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
      @request_options = Utils::RequestOptionsValidator.validate(val).freeze
    end

    ##
    # Sets max_retries with validation.
    #
    # @param [Integer] value a non-negative integer
    # @raise [Asimov::ConfigurationError] if value is not a non-negative integer
    ##
    def max_retries=(value)
      unless value.is_a?(Integer) && value >= 0
        raise Asimov::ConfigurationError, "max_retries must be a non-negative integer"
      end

      @max_retries = value
    end

    ##
    # Sets log_level with validation.
    #
    # @param [Symbol] value one of :debug, :info, :warn, :error, :fatal
    # @raise [Asimov::ConfigurationError] if value is not a valid log level
    ##
    def log_level=(value)
      unless VALID_LOG_LEVELS.include?(value)
        raise Asimov::ConfigurationError,
              "log_level must be one of: #{VALID_LOG_LEVELS.join(', ')}"
      end

      @log_level = value
    end
  end
end
