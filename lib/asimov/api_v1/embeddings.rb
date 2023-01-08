module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/embeddings" URI subspace.
    ##
    class Embeddings < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        json_post(path: "/embeddings", parameters: parameters)
      end
    end
  end
end
