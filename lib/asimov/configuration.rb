require_relative "utils/request_options_validator"

module Asimov
  ##
  # Application-wide configuration for the Asimov library. Should be
  # configured once using the Asimov.configure method on application
  # startup.
  ##
  class Configuration
    attr_accessor :api_key, :organization_id

    attr_reader :request_options

    def initialize
      reset
    end

    def reset
      @api_key = nil
      @organization_id = nil
      @request_options = {}
    end

    def request_options=(val)
      @request_options = Utils::RequestOptionsValidator.validate(val)
    end
  end
end
