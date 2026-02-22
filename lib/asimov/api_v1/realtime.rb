require "websocket-client-simple"
require_relative "realtime/session"

module Asimov
  module ApiV1
    ##
    # Class interface for the OpenAI Realtime API (WebSocket).
    ##
    class Realtime
      REALTIME_BASE = "wss://api.openai.com/v1/realtime".freeze
      private_constant :REALTIME_BASE

      def initialize(client: nil)
        @client = client
      end

      ##
      # Opens a WebSocket connection to the Realtime API and yields a Session.
      # The connection is automatically closed when the block returns or raises.
      #
      # @param [String] model the model to use (e.g. "gpt-4o-realtime")
      # @param [Hash] parameters additional query parameters (e.g. voice)
      # @yield [Asimov::ApiV1::Realtime::Session] the session for sending/receiving events
      # @raise [Asimov::MissingRequiredParameterError] if model is missing
      ##
      def connect(model:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model

        ws = open_websocket(model, parameters)
        session = Session.new(ws)
        yield session
      ensure
        if session
          session.close
        elsif ws
          ws.close
        end
      end

      private

      def open_websocket(model, parameters)
        url = build_url(model, parameters)
        headers = websocket_headers
        WebSocket::Client::Simple.connect(url, headers: headers)
      end

      def build_url(model, parameters)
        query = URI.encode_www_form(parameters.merge(model: model))
        "#{REALTIME_BASE}?#{query}"
      end

      def websocket_headers
        {
          "Authorization" => "Bearer #{@client.api_key}",
          "OpenAI-Beta" => "realtime=v1"
        }
      end
    end
  end
end
