require_relative "asimov/version"
require_relative "asimov/api_type"
require_relative "asimov/configuration"
require_relative "asimov/error"
require_relative "asimov/client"

##
# Top level module for the Asimov client library for using the OpenAI API.
##
module Asimov
  ##
  # Method uses to initialize the application-wide configuration.  Should be called with
  # a block like so:
  #
  # Asimov.configure do |config|
  #   config.api_key = 'abcd'
  #   config.organization = 'def'
  # end
  #
  # Attributes that can be set on the configuration include:
  #
  # api_key - The OpenAI API key that Asimov::Client instances should use by default.
  # organization_id - The OpenAI organization identifier that Asimov::Client instances should
  #                   use by default.
  ##
  def self.configure
    yield(configuration)
  end

  ##
  # Getter for the application-wide Asimove::Configuration singleton.
  ##
  def self.configuration
    @configuration ||= Asimov::Configuration.new
  end
end
