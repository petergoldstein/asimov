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
      # @param [String] model the model to use for the completion
      # @param [Hash] parameters the set of parameters being passed to the API
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
      # Creates a transcription request with the specified parameters.
      #
      # @param [String] model the model to use for the completion
      # @param [Hash] parameters the set of parameters being passed to the API
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
