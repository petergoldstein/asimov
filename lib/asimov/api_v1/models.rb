module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/models" URI subspace.
    ##
    class Models < Base
      URI_PREFIX = "/models".freeze
      private_constant :URI_PREFIX

      ##
      # Lists the models accessible to this combination of OpenAI API
      # key and organization id.
      ##
      def list
        http_get(path: URI_PREFIX)
      end

      ##
      # Retrieve information about the model with the specified
      # model_id.
      #
      # @param [String] model_id the id of the model to be retrieved
      ##
      def retrieve(model_id:)
        http_get(path: "#{URI_PREFIX}/#{model_id}")
      end

      ##
      # Deletes the model with the specified model_id.  Only
      # works on models created via fine tuning.
      #
      # @param [String] model_id the id of the model to be deleted
      ##
      def delete(model_id:)
        http_delete(resource: "models", id: model_id)
      end
    end
  end
end
