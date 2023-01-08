module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/models" URI subspace.
    ##
    class Models < Base
      URI_PREFIX = "/models".freeze

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
