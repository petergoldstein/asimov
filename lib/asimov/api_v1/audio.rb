require_relative "../utils/chat_messages_validator"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/audio" URI subspace.
    ##
    class Audio < Base
      RESOURCE = "audio".freeze
      private_constant :RESOURCE

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

      ##
      # Creates a text-to-speech request. When writer is provided, streams
      # binary audio to it. Otherwise returns the raw audio binary data.
      #
      # @param [String] model the TTS model (e.g., "tts-1", "tts-1-hd")
      # @param [String] input the text to synthesize
      # @param [String] voice the voice to use (e.g., "alloy", "echo", "fable")
      # @param [IO, nil] writer optional IO object to stream audio to
      # @param [Hash] parameters additional parameters (response_format, speed, etc.)
      ##
      def create_speech(model:, input:, voice:, writer: nil, parameters: {})
        validate_speech_params(model, input, voice)
        send_speech_request(parameters.merge(model: model, input: input, voice: voice), writer)
      end

      private

      def send_speech_request(merged, writer)
        if writer
          rest_create_w_json_params_streamed_download(
            resource: [RESOURCE, "speech"], parameters: merged, writer: writer
          )
        else
          rest_create_w_json_params_binary(
            resource: [RESOURCE, "speech"], parameters: merged
          )
        end
      end

      def validate_speech_params(model, input, voice)
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:input) unless input
        raise MissingRequiredParameterError.new(:voice) unless voice
      end

      def open_file(parameters)
        raise MissingRequiredParameterError.new(:file) unless parameters[:file]

        parameters.merge(file: Utils::FileManager.open(parameters[:file]))
      end
    end
  end
end
