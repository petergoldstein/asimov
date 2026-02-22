module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/moderations" URI subspace.
    ##
    class Moderations < Base
      RESOURCE = "moderations".freeze
      private_constant :RESOURCE

      ##
      # Calls the /moderations POST endpoint with the specified parameters.
      #
      # @param [String] input the text being evaluated by the API
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def create(input:, parameters: {})
        raise MissingRequiredParameterError.new(:input) unless input

        rest_create_w_json_params(resource: RESOURCE,
                                  parameters: parameters.merge({ input: input }))
      end
    end
  end
end
