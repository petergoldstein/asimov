module Asimov
  module ApiV1
    class Embeddings < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        json_post(path: "/embeddings", parameters: parameters)
      end
    end
  end
end
