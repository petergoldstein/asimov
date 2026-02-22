module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/embeddings" URI subspace.
    ##
    class Embeddings < Base
      RESOURCE = "embeddings".freeze
      private_constant :RESOURCE

      ##
      # Creates an embedding resource with the specified parameters.
      #
      # @param [String] model the id for the model used to create the embedding
      # @param [String] parameters the (optional) additional parameters being
      # provided to inform embedding creation.
      ##
      def create(model:, input:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:input) unless input

        rest_create_w_json_params(resource: RESOURCE,
                                  parameters: parameters.merge({
                                                                 model: model, input: input
                                                               }))
      end
    end
  end
end
