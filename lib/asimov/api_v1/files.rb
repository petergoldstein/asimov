require_relative "../utils/file_manager"
require_relative "../utils/jsonl_validator"

module Asimov
  module ApiV1
    class Files < Base
      URI_PREFIX = "/v1/files".freeze

      def list
        http_get(path: URI_PREFIX)
      end

      def upload(parameters:)
        raise MissingRequiredParameterError.new(:file) unless parameters[:file]
        raise MissingRequiredParameterError.new(:purpose) unless parameters[:purpose]

        validate(parameters[:file])

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

      def content(file_id:)
        http_get(path: "#{URI_PREFIX}/#{file_id}/content")
      end

      private

      def validate(filename)
        Utils::JsonlValidator.validate(Utils::FileManager.open(filename))
      end
    end
  end
end
