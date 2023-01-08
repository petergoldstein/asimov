module Asimov
  module ApiV1
    class Base
      extend Forwardable

      def initialize(client: nil)
        @client = client
      end
      def_delegators :@client, :http_delete, :http_get, :json_post, :multipart_post
    end
  end
end
