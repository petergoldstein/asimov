module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/edits" URI subspace.
    ##
    class Edits < Base
      ##
      # Creates an edit resource with the specified parameters.
      #
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def create(model:, instruction:, parameters: {})
        disallow_azure
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:instruction) unless instruction

        rest_create_w_json_params(resource: "edits",
                                  parameters: parameters.merge({ model: model,
                                                                 instruction: instruction }))
      end
    end
  end
end
