module Asimov
  module ApiV1
    class Finetunes < Base
      URI_PREFIX = "/v1/fine-tunes".freeze

      def list
        http_get(path: URI_PREFIX)
      end

      def create(parameters:)
        raise MissingRequiredParameterError.new(:training_file) unless parameters[:training_file]

        json_post(path: URI_PREFIX, parameters: parameters)
      end

      def retrieve(fine_tune_id:)
        http_get(path: "#{URI_PREFIX}/#{fine_tune_id}")
      end

      def cancel(fine_tune_id:)
        multipart_post(path: "#{URI_PREFIX}/#{fine_tune_id}/cancel")
      end

      def events(fine_tune_id:)
        http_get(path: "#{URI_PREFIX}/#{fine_tune_id}/events")
      end
    end
  end
end
