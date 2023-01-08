module Asimov
  module ApiV1
    class Base
      extend Forwardable
      include HTTParty

      base_uri "https://api.openai.com/v1"

      def initialize(client: nil)
        @client = client
      end
      def_delegators :@client, :headers

      def http_delete(path:)
        self.class.delete(
          path,
          headers: headers
        ).parsed_response
      end

      def http_get(path:)
        self.class.get(
          path,
          { headers: headers }
        ).parsed_response
      end

      def json_post(path:, parameters:)
        self.class.post(
          path,
          { headers: headers,
            body: parameters&.to_json }
        ).parsed_response
      end

      def multipart_post(path:, parameters: nil)
        self.class.post(
          path,
          { headers: headers("multipart/form-data"),
            body: parameters }
        ).parsed_response
      end
    end
  end
end
