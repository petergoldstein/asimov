module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/completions" URI subspace.
    ##
    class Completions < Base
      ##
      # Calls the /completions POST endpoint with the specified parameters.
      #
      # @param [String] model the model to use for the completion
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def create(model:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise StreamingResponseNotSupportedError if parameters[:stream]

        json_post(path: "/completions", parameters: parameters.merge({ model: model }))
      end
    end
  end
end
