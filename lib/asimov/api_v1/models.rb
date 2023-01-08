module Asimov
  module ApiV1
    class Models < Base
      URI_PREFIX = "/v1/models".freeze

      def list
        http_get(path: URI_PREFIX)
      end

      def retrieve(model_id:)
        http_get(path: "#{URI_PREFIX}/#{model_id}")
      end

      def delete(model_id:)
        http_delete(path: "#{URI_PREFIX}/#{model_id}")
      end
    end
  end
end
