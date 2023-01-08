module Asimov
  module ApiV1
    class Completions < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]

        json_post(path: "/completions", parameters: parameters)
      end
    end
  end
end
