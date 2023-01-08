module Asimov
  module ApiV1
    module Dtos
      class File
        attr_reader :id, :bytes, :filename, :purpose

        def initialize(hsh)
          @id = hsh["id"]
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
