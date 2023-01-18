module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/completions" URI subspace.
    ##
    class Completions < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise StreamingResponseNotSupportedError if parameters[:stream]

        json_post(path: "/completions", parameters: parameters)
      end
    end
  end
end
