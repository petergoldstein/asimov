module Asimov
  module ApiV1
    class Edits < Base
      def create(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise MissingRequiredParameterError.new(:instruction) unless parameters[:instruction]

        json_post(path: "/edits", parameters: parameters)
      end
    end
  end
end
