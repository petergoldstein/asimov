module Asimov
  module ApiV1
    class Moderations < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        json_post(path: "/v1/moderations", parameters: parameters)
      end
    end
  end
end
