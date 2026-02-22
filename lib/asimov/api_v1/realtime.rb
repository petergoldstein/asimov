require "websocket-client-simple"

module Asimov
  module ApiV1
    ##
    # Class interface for the OpenAI Realtime API.
    # Provides both WebSocket connectivity and REST endpoints for
    # client secrets and call management.
    ##
    class Realtime < Base
      require_relative "realtime/session"
      REALTIME_BASE = "wss://api.openai.com/v1/realtime".freeze
      private_constant :REALTIME_BASE

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

      ##
      # Creates a client secret for ephemeral authentication.
      #
      # @param [Hash] parameters optional session config (model, voice, instructions, tools, etc.)
      #   and expires_after
      # @return [Hash] the client secret object
      ##
      def create_client_secret(parameters: {})
        rest_create_w_json_params(resource: %w[realtime client_secrets],
                                  parameters: parameters)
      end

      ##
      # Accepts an incoming call.
      #
      # @param [String] call_id the ID of the call to accept
      # @param [Hash] parameters optional parameters for the accept action
      # @return [Hash] the call object
      ##
      def accept_call(call_id:, parameters: {})
        raise MissingRequiredParameterError.new(:call_id) unless call_id

        rest_create_w_json_params(
          resource: ["realtime", "calls", call_id, "accept"],
          parameters: parameters
        )
      end

      ##
      # Hangs up an active call.
      #
      # @param [String] call_id the ID of the call to hang up
      # @return [Hash] the call object
      ##
      def hangup_call(call_id:)
        raise MissingRequiredParameterError.new(:call_id) unless call_id

        rest_create_w_json_params(
          resource: ["realtime", "calls", call_id, "hangup"],
          parameters: nil
        )
      end

      ##
      # Refers (transfers) a call to another URI.
      #
      # @param [String] call_id the ID of the call to refer
      # @param [String] target_uri the SIP URI to transfer the call to
      # @param [Hash] parameters optional additional parameters
      # @return [Hash] the call object
      ##
      def refer_call(call_id:, target_uri:, parameters: {})
        raise MissingRequiredParameterError.new(:call_id) unless call_id

        rest_create_w_json_params(
          resource: ["realtime", "calls", call_id, "refer"],
          parameters: { target_uri: target_uri }.merge(parameters)
        )
      end

      ##
      # Rejects an incoming call.
      #
      # @param [String] call_id the ID of the call to reject
      # @param [Hash] parameters optional parameters (e.g. reason)
      # @return [Hash] the call object
      ##
      def reject_call(call_id:, parameters: {})
        raise MissingRequiredParameterError.new(:call_id) unless call_id

        rest_create_w_json_params(
          resource: ["realtime", "calls", call_id, "reject"],
          parameters: parameters
        )
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
          "Authorization" => "Bearer #{@client.api_key}"
        }
      end
    end
  end
end
