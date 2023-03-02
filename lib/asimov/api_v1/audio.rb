require_relative "../utils/chat_messages_validator"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/audio" URI subspace.
    ##
    class Audio < Base
      RESOURCE = "audio".freeze

      ##
      # Creates a transcription request with the specified parameters.
      #
      # @param [String] file the name of the file to transcribe
      # @param [String] model the model to use for the transcription
      # @param [Hash] parameters the (optional) additional parameters
      #               being passed to the API
      ##
      def create_transcription(file:, model:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model

        rest_create_w_multipart_params(resource: [RESOURCE, "transcriptions"],
                                       parameters:
                                       open_file(parameters.merge({
                                                                    file: file, model: model
                                                                  })))
      end

      ##
      # Creates a translation request with the specified parameters.
      #
      # @param [String] file the name of the file to translate
      # @param [String] model the model to use for the translation
      # @param [Hash] parameters the (optional) additional parameters
      #               being passed to the API
      ##
      def create_translation(file:, model:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model

        rest_create_w_multipart_params(resource: [RESOURCE, "translations"],
                                       parameters:
                                       open_file(parameters.merge({
                                                                    file: file, model: model
                                                                  })))
      end

      private

      def open_file(parameters)
        raise MissingRequiredParameterError.new(:file) unless parameters[:file]

        parameters.merge(file: Utils::FileManager.open(parameters[:file]))
      end
    end
  end
end
