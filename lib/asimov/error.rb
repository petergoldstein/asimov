module Asimov
  ##
  # Parent error for all Asimov gem errors.
  ##
  class Error < StandardError; end

  ##
  # Errors that occur when initializing an Asimov::Client.
  ##
  class ConfigurationError < Error; end

  ##
  # Error that occurs when there is no configured
  # API key for a newly created Asimov::Client.
  ##
  class MissingApiKeyError < ConfigurationError; end

  ##
  # Error that occurs when there is no configured
  # base URI for a newly created Asimov::Client.
  ##
  class MissingBaseUriError < ConfigurationError; end

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
  # Error that occurs because the provided API key is not
  # valid.
  ##
  class InvalidApiKeyError < AuthorizationError; end

  ##
  # Error that occurs because the provided API key is not
  # valid.
  ##
  class InvalidOrganizationError < AuthorizationError; end

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

    ##
    # Returns the error message based on the file name and the wrapped error.
    ##
    def message
      "The file #{@file_name} could not be opened for upload because of the " \
        "following error - #{@system_message}."
    end
  end

  ##
  # Error that occurs when a JSONL file is expected
  # and it cannot be parsed.
  ##
  class JsonlFileCannotBeParsedError < FileDataError; end

  ##
  # Error that occurs when an invalid training example
  # is found in a training file.
  ##
  class InvalidTrainingExampleError < FileDataError; end

  ##
  # Error that occurs when an invalid text entry
  # is found in a text entry file.
  ##
  class InvalidTextEntryError < FileDataError; end

  ##
  # Error that occurs when an invalid classification
  # is found in a classifications file.
  ##
  class InvalidClassificationError < FileDataError; end

  ##
  # Error that occurs when an invalid value is provided
  # for an expected parameter in a request.
  ##
  class InvalidParameterValueError < RequestError; end

  ##
  # Error that occurs when an unexpected parameter is
  # provided in a request.
  ##
  class UnsupportedParameterError < RequestError; end

  ##
  # Error raised when a required parameter is not included
  # in the request.
  ##
  class MissingRequiredParameterError < RequestError
    def initialize(parameter_name)
      super()
      @parameter_name = parameter_name
    end

    ##
    # Returns the error message based on the missing parameter name.
    ##
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

  ##
  # Errors that occur because the OpenAI API returned
  # an HTTP code 429.  This typically occurs because
  # you have hit a rate limit or quota limit, or
  # because the engine is overloaded.
  ##
  class TooManyRequestsError < RequestError; end

  ##
  # Error that occurs when the quota for an API key
  # is exceeded.
  ##
  class QuotaExceededError < TooManyRequestsError; end

  ##
  # Error that occurs when the rate limit for requests
  # is exceeded.
  ##
  class RateLimitError < TooManyRequestsError; end

  ##
  # Error that occurs when the API itself is
  # overloaded and temporarily cannot accept additional
  # requests.
  ##
  class ApiOverloadedError < TooManyRequestsError; end

  ##
  # Raised when a non-false stream parameter is passed
  # to certain API methods.  Processing of server-side
  # events using the stream parameter is currently not
  # supported.
  ##
  class StreamingResponseNotSupportedError < RequestError; end
end
