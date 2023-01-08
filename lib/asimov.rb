require_relative "asimov/version"
require_relative "asimov/configuration"
require_relative "asimov/error"
require_relative "asimov/client"

module Asimov
  def self.configuration
    @configuration ||= Asimov::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
