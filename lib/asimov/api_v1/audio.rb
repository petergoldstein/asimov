require_relative "../utils/file_manager"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/audio" URI subspace.
    ##
    class Audio < Base
      RESOURCE = "audio".freeze
      VOICE_CONSENTS_RESOURCE = [RESOURCE, "voice_consents"].freeze
      private_constant :RESOURCE, :VOICE_CONSENTS_RESOURCE

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

      ##
      # Creates a custom voice from an audio sample and a voice consent.
      #
      # @param [String] name the name of the voice
      # @param [String] consent the ID of the voice consent
      # @param [String] audio_sample file name or a File-like object for the audio sample
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created voice object
      ##
      def create_voice(name:, consent:, audio_sample:, parameters: {})
        raise MissingRequiredParameterError.new(:name) unless name
        raise MissingRequiredParameterError.new(:consent) unless consent
        raise MissingRequiredParameterError.new(:audio_sample) unless audio_sample

        rest_create_w_multipart_params(
          resource: [RESOURCE, "voices"],
          parameters: parameters.merge(name: name, consent: consent,
                                       audio_sample: Utils::FileManager.open(audio_sample))
        )
      end

      ##
      # Creates a voice consent recording.
      #
      # @param [String] name the name of the voice consent
      # @param [String] language the language of the recording
      # @param [String] recording file name or a File-like object for the recording
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created voice consent object
      ##
      def create_voice_consent(name:, language:, recording:, parameters: {})
        raise MissingRequiredParameterError.new(:name) unless name
        raise MissingRequiredParameterError.new(:language) unless language
        raise MissingRequiredParameterError.new(:recording) unless recording

        rest_create_w_multipart_params(
          resource: VOICE_CONSENTS_RESOURCE,
          parameters: parameters.merge(name: name, language: language,
                                       recording: Utils::FileManager.open(recording))
        )
      end

      ##
      # Lists voice consents.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing voice consent objects
      ##
      def list_voice_consents(parameters: {})
        rest_index(resource: VOICE_CONSENTS_RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a voice consent by ID.
      #
      # @param [String] consent_id the ID of the voice consent
      # @return [Hash] the voice consent object
      ##
      def retrieve_voice_consent(consent_id:)
        raise MissingRequiredParameterError.new(:consent_id) unless consent_id

        rest_get(resource: resource_path(VOICE_CONSENTS_RESOURCE), id: consent_id)
      end

      ##
      # Updates a voice consent.
      #
      # @param [String] consent_id the ID of the voice consent to update
      # @param [String] name the new name for the voice consent
      # @param [Hash] parameters additional parameters
      # @return [Hash] the updated voice consent object
      ##
      def update_voice_consent(consent_id:, name:, parameters: {})
        raise MissingRequiredParameterError.new(:consent_id) unless consent_id
        raise MissingRequiredParameterError.new(:name) unless name

        rest_create_w_json_params(
          resource: VOICE_CONSENTS_RESOURCE + [consent_id],
          parameters: parameters.merge(name: name)
        )
      end

      ##
      # Deletes a voice consent by ID.
      #
      # @param [String] consent_id the ID of the voice consent to delete
      # @return [Hash] deletion confirmation
      ##
      def delete_voice_consent(consent_id:)
        raise MissingRequiredParameterError.new(:consent_id) unless consent_id

        rest_delete(resource: resource_path(VOICE_CONSENTS_RESOURCE), id: consent_id)
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
