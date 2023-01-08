module Asimov
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class MissingAccessTokenError < ConfigurationError
    def message
      "OpenAI access token missing! See https://github.com/alexrudall/ruby-openai#usage"
    end
  end

  class FileCannotBeOpenedError < Asimov::Error
    def initialize(file_name, system_message)
      super()
      @file_name = file_name
      @system_message = system_message
    end

    def message
      "The file #{@file_name} could not be opened for upload because of the " \
        "following error - #{@system_message}."
    end
  end

  class JsonlFileCannotBeParsedError < Asimov::Error
    def initialize(file_name = "<unknown>", system_message = "<parsing error>")
      super()
      @file_name = file_name
      @system_message = system_message
    end

    def message
      "The JSONL file #{@file_name} could not be parsed because of the following " \
        "error - #{@system_message}."
    end
  end

  class MissingRequiredParameterError < Asimov::Error
    def initialize(parameter_name)
      super()
      @parameter_name = parameter_name
    end

    def message
      "The parameter #{@parameter_name} is required."
    end
  end
end
