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

      ##
      # Lists files that have been uploaded to OpenAI
      ##
      def list
        http_get(path: URI_PREFIX)
      end

      def upload(parameters:)
        raise MissingRequiredParameterError.new(:file) unless parameters[:file]
        raise MissingRequiredParameterError.new(:purpose) unless parameters[:purpose]

        validate(parameters[:file], parameters[:purpose])

        multipart_post(
          path: URI_PREFIX,
          parameters: parameters.merge(file: Utils::FileManager.open(parameters[:file]))
        )
      end

      def retrieve(file_id:)
        http_get(path: "#{URI_PREFIX}/#{file_id}")
      end

      def delete(file_id:)
        http_delete(path: "#{URI_PREFIX}/#{file_id}")
      end

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
