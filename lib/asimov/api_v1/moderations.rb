module Asimov
  module ApiV1
    class Moderations < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        json_post(path: "/moderations", parameters: parameters)
      end
    end
  end
end
