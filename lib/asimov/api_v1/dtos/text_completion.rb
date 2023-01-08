module Asimov
  module ApiV1
    module Dtos
      class TextCompletion
        attr_reader :id, :model_id, :choices

        def initialize(hsh)
          @id = hsh["id"]
          @model_id = hsh["model"]
          @created = hsh["created"]
        end

        def created_at
          return nil if @created.nil?

          @created_at ||= Time.at(@created).utc
        end
      end
    end
  end
end
