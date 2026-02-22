module Asimov
  module ApiV1
    class Realtime
      ##
      # Wraps a WebSocket connection to the OpenAI Realtime API.
      # Handles JSON serialization/deserialization and event routing.
      ##
      class Session
        attr_reader :connected

        def initialize(websocket)
          @websocket = websocket
          @handlers = {}
          @connected = false
          setup_ws_handlers
        end

        ##
        # Registers a handler for a specific event type.
        #
        # @param [String, Symbol] event_type the event type to listen for
        #   (e.g. "message", "open", "close", "error", or API event types)
        # @yield [Hash, nil] the parsed event data
        ##
        def on(event_type, &block)
          @handlers[event_type.to_s] = block
        end

        ##
        # Sends a JSON-encoded event to the WebSocket.
        #
        # @param [Hash] event the event to send (will be serialized to JSON)
        ##
        def send_event(event)
          @websocket.send(event.to_json)
        end

        ##
        # Closes the WebSocket connection.
        ##
        def close
          @websocket.close
        end

        private

        attr_writer :connected

        def setup_ws_handlers
          setup_open_handler
          setup_message_handler
          setup_error_handler
          setup_close_handler
        end

        def setup_open_handler
          session = self
          @websocket.on(:open) do
            session.send(:connected=, true)
            session.send(:dispatch, "open", nil)
          end
        end

        def setup_message_handler
          session = self
          @websocket.on(:message) { |msg| session.send(:handle_message, msg) }
        end

        def setup_error_handler
          session = self
          @websocket.on(:error) { |err| session.send(:dispatch, "error", err) }
        end

        def setup_close_handler
          session = self
          @websocket.on(:close) do
            session.send(:connected=, false)
            session.send(:dispatch, "close", nil)
          end
        end

        def handle_message(msg)
          data = JSON.parse(msg.data)
          event_type = data["type"]
          dispatch("message", data)
          dispatch(event_type, data) if event_type
        rescue JSON::ParserError
          dispatch("message", { "raw" => msg.data })
        end

        def dispatch(event_type, data)
          handler = @handlers[event_type]
          handler&.call(data)
        end
      end
    end
  end
end
