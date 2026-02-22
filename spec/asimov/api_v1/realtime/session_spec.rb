require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::Realtime::Session do
  subject(:session) { described_class.new(websocket) }

  let(:websocket) { instance_double(WebSocket::Client::Simple::Client) }
  let(:handlers) { {} }

  before do
    allow(websocket).to receive(:on) do |event_type, &block|
      handlers[event_type] = block
    end
  end

  describe "#send_event" do
    let(:event) { { type: "conversation.item.create", item: { content: "hello" } } }

    it "sends JSON-encoded event to the WebSocket" do
      allow(websocket).to receive(:send)
      session.send_event(event)
      expect(websocket).to have_received(:send).with(event.to_json)
    end
  end

  describe "#close" do
    it "closes the WebSocket connection" do
      allow(websocket).to receive(:close)
      session.close
      expect(websocket).to have_received(:close)
    end
  end

  describe "#on" do
    it "registers an event handler" do
      handler_called = false
      session.on(:message) { |_data| handler_called = true }
      expect(handler_called).to be false
    end
  end

  describe "WebSocket event handling" do
    describe "open event" do
      it "sets connected to true and dispatches open event" do
        open_data = nil
        session.on("open") { |data| open_data = data }

        expect(session.connected).to be false
        handlers[:open]&.call
        expect(session.connected).to be true
        expect(open_data).to be_nil
      end
    end

    describe "message event" do
      it "parses JSON and dispatches to message and type-specific handlers" do
        message_data = nil
        type_data = nil
        session.on("message") { |data| message_data = data }
        session.on("response.created") { |data| type_data = data }

        json = '{"type":"response.created","response":{"id":"resp_1"}}'
        msg = Struct.new(:data).new(json)
        handlers[:message]&.call(msg)

        expected = { "type" => "response.created",
                     "response" => { "id" => "resp_1" } }
        expect(message_data).to eq(expected)
        expect(type_data).to eq(expected)
      end

      it "dispatches raw data on JSON parse error" do
        message_data = nil
        session.on("message") { |data| message_data = data }

        msg = Struct.new(:data).new("not valid json")
        handlers[:message]&.call(msg)

        expect(message_data).to eq({ "raw" => "not valid json" })
      end
    end

    describe "error event" do
      it "dispatches error to the error handler" do
        error_data = nil
        session.on("error") { |data| error_data = data }

        error = StandardError.new("ws error")
        handlers[:error]&.call(error)

        expect(error_data).to eq(error)
      end
    end

    describe "close event" do
      it "sets connected to false and dispatches close event" do
        close_called = false
        session.on("close") { |_data| close_called = true }

        # Simulate open first
        handlers[:open]&.call
        expect(session.connected).to be true

        handlers[:close]&.call
        expect(session.connected).to be false
        expect(close_called).to be true
      end
    end
  end
end
