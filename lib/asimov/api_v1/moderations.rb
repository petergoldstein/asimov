module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/moderations" URI subspace.
    ##
    class Moderations < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        json_post(path: "/moderations", parameters: parameters)
      end
    end
  end
end
