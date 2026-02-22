require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Realtime do
  subject(:realtime) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }

  describe "#connect" do
    let(:model) { "gpt-4o-realtime" }
    let(:ws_double) { instance_double(WebSocket::Client::Simple::Client) }

    before do
      allow(ws_double).to receive(:on)
      allow(ws_double).to receive(:close)
      allow(WebSocket::Client::Simple).to receive(:connect).and_return(ws_double)
    end

    context "when model is present" do
      it "opens a WebSocket connection and yields a session" do
        session = nil
        realtime.connect(model: model) { |s| session = s }
        expect(session).to be_a(Asimov::ApiV1::Realtime::Session)
        expect(WebSocket::Client::Simple).to have_received(:connect).with(
          %r{wss://api\.openai\.com/v1/realtime\?model=#{model}},
          headers: hash_including("Authorization" => "Bearer #{api_key}",
                                  "OpenAI-Beta" => "realtime=v1")
        )
      end

      it "includes additional parameters in the URL" do
        realtime.connect(model: model, parameters: { voice: "alloy" }) { |s| s }
        expect(WebSocket::Client::Simple).to have_received(:connect).with(
          /voice=alloy/,
          headers: anything
        )
      end

      it "closes the WebSocket when the block completes normally" do
        realtime.connect(model: model) { |_s| nil }
        expect(ws_double).to have_received(:close)
      end

      it "closes the WebSocket when the block raises an exception" do
        expect do
          realtime.connect(model: model) { |_s| raise "boom" }
        end.to raise_error(RuntimeError, "boom")
        expect(ws_double).to have_received(:close)
      end

      it "closes the raw WebSocket when Session.new raises" do
        allow(Asimov::ApiV1::Realtime::Session).to receive(:new)
          .and_raise(RuntimeError, "init failed")
        expect do
          realtime.connect(model: model) { |_s| nil }
        end.to raise_error(RuntimeError, "init failed")
        expect(ws_double).to have_received(:close)
      end
    end

    context "when model is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          realtime.connect(model: nil) { |s| s }
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end
end
