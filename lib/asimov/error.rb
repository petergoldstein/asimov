module Asimov
  ##
  # Parent error for all Asimov gem errors.
  ##
  class Error < StandardError; end

  ##
  # Errors that occur when initializing an Asimov::Client.
  ##
  class ConfigurationError < Error; end

  class MissingApiKeyError < ConfigurationError; end

  ##
  # Errors that occur when making an API request.  They
  # can occur either through local validation or
  # as a result of an error returned by the OpenAI API.
  ##
  class RequestError < Error; end

  ##
  # Errors that occur as a result of an error raised
  # by the underlying network client.  Examples
  # include Net::OpenTimeout or Net::ReadTimeout
  ##
  class NetworkError < RequestError; end

  ##
  # Errors that occur as a result of a timeout raised
  # by the underlying network client.  Examples
  # include Net::OpenTimeout or Net::ReadTimeout
  ##
  class TimeoutError < NetworkError; end

  ##
  # Error that occurs as a result of a Net::OpenTimeout raised
  # by the underlying network client.
  ##
  class OpenTimeout < TimeoutError; end

  ##
  # Error that occurs as a result of a Net::ReadTimeout raised
  # by the underlying network client.
  ##
  class ReadTimeout < TimeoutError; end

  ##
  # Error that occurs as a result of a Net::WriteTimeout raised
  # by the underlying network client.
  ##
  class WriteTimeout < TimeoutError; end

  ##
  # Errors that occur as a result of an HTTP 401
  # returned by the OpenAI API.
  ##
  class AuthorizationError < RequestError; end

  ##
  # Errors that occur because of issues with the
  # parameters of a request.  Typically these correspond
  # to a 400 HTTP return code.  Example causes include missing
  # parameters, unexpected parameters, invalid parameter
  # values.
  #
  # Errors of this type my be geenrated through local
  # validation or as a result of an error returned by
  # the OpenAI API.
  ##
  class ParameterError < RequestError; end

  ##
  # Errors that occur because of a problem with file data
  # being provided as a part of a multipart form upload.
  # This can include the file being unreadable, or
  # formatting problems with the file.
  ##
  class FileDataError < RequestError; end

  ##
  # Error that occurs when a local file cannot be opened.
  ##
  class FileCannotBeOpenedError < FileDataError
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

  class JsonlFileCannotBeParsedError < FileDataError; end

  class InvalidTrainingExampleError < FileDataError; end

  class InvalidTextEntryError < FileDataError; end

  class InvalidClassificationError < FileDataError; end

  class InvalidParameterValueError < RequestError; end

  class UnsupportedParameterError < RequestError; end

  ##
  #
  ##
  class MissingRequiredParameterError < RequestError
    def initialize(parameter_name)
      super()
      @parameter_name = parameter_name
    end

    def message
      "The parameter #{@parameter_name} is required."
    end
  end

  ##
  # Errors that occur because the OpenAI API returned
  # an HTTP code 400.  This typically occurs because
  # one or more provided identifiers do not match
  # an object in the OpenAI system.
  ##
  class NotFoundError < RequestError; end
end
