require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Realtime do
  subject(:realtime) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "realtime" }

  it_behaves_like "sends requests to the v1 API"

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
          headers: hash_including("Authorization" => "Bearer #{api_key}")
        )
      end

      it "does not include the OpenAI-Beta header" do
        realtime.connect(model: model) { |s| s }
        expect(WebSocket::Client::Simple).to have_received(:connect).with(
          anything,
          headers: hash_not_including("OpenAI-Beta")
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

  describe "#create_client_secret" do
    it "calls rest_create_w_json_params with the expected arguments" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: %w[realtime client_secrets], parameters: parameters)
        .and_return(ret_val)
      expect(realtime.create_client_secret(parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: %w[realtime client_secrets], parameters: {})
        .and_return(ret_val)
      expect(realtime.create_client_secret).to eq(ret_val)
    end
  end

  describe "#accept_call" do
    let(:call_id) { "call_#{SecureRandom.hex(4)}" }

    context "when call_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          realtime.accept_call(call_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "accept"], parameters: parameters)
        .and_return(ret_val)
      expect(realtime.accept_call(call_id: call_id, parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "accept"], parameters: {})
        .and_return(ret_val)
      expect(realtime.accept_call(call_id: call_id)).to eq(ret_val)
    end
  end

  describe "#hangup_call" do
    let(:call_id) { "call_#{SecureRandom.hex(4)}" }

    context "when call_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          realtime.hangup_call(call_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with nil parameters" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "hangup"], parameters: nil)
        .and_return(ret_val)
      expect(realtime.hangup_call(call_id: call_id)).to eq(ret_val)
    end
  end

  describe "#refer_call" do
    let(:call_id) { "call_#{SecureRandom.hex(4)}" }
    let(:target_uri) { "sip:+15551234567@example.com" }

    context "when call_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          realtime.refer_call(call_id: nil, target_uri: target_uri)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with target_uri merged into parameters" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "refer"],
              parameters: { target_uri: target_uri }.merge(parameters))
        .and_return(ret_val)
      expect(realtime.refer_call(call_id: call_id, target_uri: target_uri,
                                 parameters: parameters)).to eq(ret_val)
    end

    it "defaults to only target_uri in parameters" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "refer"],
              parameters: { target_uri: target_uri })
        .and_return(ret_val)
      expect(realtime.refer_call(call_id: call_id, target_uri: target_uri)).to eq(ret_val)
    end
  end

  describe "#reject_call" do
    let(:call_id) { "call_#{SecureRandom.hex(4)}" }

    context "when call_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          realtime.reject_call(call_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "reject"], parameters: parameters)
        .and_return(ret_val)
      expect(realtime.reject_call(call_id: call_id, parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(realtime).to receive(:rest_create_w_json_params)
        .with(resource: ["realtime", "calls", call_id, "reject"], parameters: {})
        .and_return(ret_val)
      expect(realtime.reject_call(call_id: call_id)).to eq(ret_val)
    end
  end
end
