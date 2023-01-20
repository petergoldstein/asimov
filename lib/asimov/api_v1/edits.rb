module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/edits" URI subspace.
    ##
    class Edits < Base
      ##
      # Calls the /edits POST endpoint with the specified parameters.
      #
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def create(model:, instruction:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:instruction) unless instruction

        json_post(path: "/edits",
                  parameters: parameters.merge({ model: model,
                                                 instruction: instruction }))
      end
    end
  end
end
