require_relative "../utils/file_manager"
require_relative "../utils/jsonl_validator"
require_relative "../utils/training_file_validator"
require_relative "../utils/classifications_file_validator"
require_relative "../utils/text_entry_file_validator"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/files" URI subspace.
    ##
    class Files < Base
      URI_PREFIX = "/files".freeze
      private_constant :URI_PREFIX

      ##
      # Lists files that have been uploaded to OpenAI
      ##
      def list
        http_get(path: URI_PREFIX)
      end

      ##
      # Uploads a file to the /files endpoint with the specified parameters.
      #
      # @param [String] file file name  or a File-like object to be uploaded
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def upload(file:, purpose:, parameters: {})
        raise MissingRequiredParameterError.new(:file) unless file
        raise MissingRequiredParameterError.new(:purpose) unless purpose

        validate(file, purpose)

        multipart_post(
          path: URI_PREFIX,
          parameters: parameters.merge(file: Utils::FileManager.open(file), purpose: purpose)
        )
      end

      ##
      # Retrieves the file with the specified file_id from OpenAI.
      #
      # @param [String] file_id the id of the file to be retrieved
      ##
      def retrieve(file_id:)
        http_get(path: "#{URI_PREFIX}/#{file_id}")
      end

      ##
      # Deletes the file with the specified file_id from OpenAI.
      #
      # @param [String] file_id the id of the file to be deleted
      ##
      def delete(file_id:)
        http_delete(path: "#{URI_PREFIX}/#{file_id}")
      end

      ##
      # Retrieves the contents of the file with the specified file_id from OpenAI
      # and passes those contents to the writer in a chunked manner.
      #
      # @param [String] file_id the id of the file to be retrieved
      # @param [Writer] writer the Writer that will process the chunked content
      # as it is received from the API
      ##
      def content(file_id:, writer:)
        http_streamed_download(path: "#{URI_PREFIX}/#{file_id}/content", writer: writer)
      end

      private

      def validate(filename, purpose)
        validator_class(purpose).new.validate(Utils::FileManager.open(filename))
      end

      def validator_class(purpose)
        case purpose
        when "fine-tune"
          Utils::TrainingFileValidator
        when "classifications"
          Utils::ClassificationsFileValidator
        when "answers", "search"
          Utils::TextEntryFileValidator
        else
          Utils::JsonlValidator
        end
      end
    end
  end
end
