module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/edits" URI subspace.
    ##
    class Edits < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise MissingRequiredParameterError.new(:instruction) unless parameters[:instruction]

        json_post(path: "/edits", parameters: parameters)
      end
    end
  end
end
