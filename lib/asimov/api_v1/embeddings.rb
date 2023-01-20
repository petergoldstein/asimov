module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/embeddings" URI subspace.
    ##
    class Embeddings < Base
      ##
      # Calls the /embeddings POST endpoint with the specified parameters.
      #
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def create(model:, input:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:input) unless input

        json_post(path: "/embeddings", parameters: parameters.merge({ model: model, input: input }))
      end
    end
  end
end
