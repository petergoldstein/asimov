module Asimov
  module ApiV1
    module Dtos
      class Usage
        attr_reader :prompt_tokens, :completion_tokens, :total_tokens

        def initialize(hsh)
          @prompt_tokens = hsh["prompt_tokens"]
          @completion_tokens = hsh["completion_tokens"]
          @total_tokens = hsh["total_tokens"]
        end
      end
    end
  end
end
