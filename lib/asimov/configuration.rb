module Asimov
  class Configuration
    attr_accessor :access_token, :organization_id

    def initialize
      reset
    end

    def reset
      @access_token = nil
      @organization_id = nil
    end
  end
end
