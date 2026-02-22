require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Retryable do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:chat) { Asimov::ApiV1::Chat.new(client: client) }
  let(:model) { "gpt-4o" }
  let(:messages) { [{ "role" => "user", "content" => "hello" }] }
  let(:success_response) do
    instance_double(HTTParty::Response, code: 200,
                                        parsed_response: { "id" => "chatcmpl-123" })
  end
  let(:rate_limit_response) { stub_response(code: 429, message: "Rate limit reached for model") }
  let(:quota_response) { stub_response(code: 429, message: "You exceeded your current quota") }
  let(:overloaded_response) do
    stub_response(code: 429, message: "The engine is currently overloaded")
  end
  let(:service_unavailable_response) { stub_response(code: 503, message: "Service unavailable") }

  def stub_response(code:, message:)
    instance_double(HTTParty::Response, code: code,
                                        parsed_response: { "error" => {
                                          "message" => message
                                        } })
  end

  describe "retry behavior" do
    context "when max_retries is 0 (default)" do
      it "does not retry on RateLimitError" do
        allow(Asimov::ApiV1::Chat).to receive(:post).and_return(rate_limit_response)
        expect do
          chat.create(model: model, messages: messages)
        end.to raise_error(Asimov::RateLimitError)
      end
    end

    context "when max_retries is greater than 0" do
      before do
        Asimov.configure { |c| c.max_retries = 2 }
        allow(chat).to receive(:sleep)
      end

      it "retries on RateLimitError and succeeds" do
        call_count = 0
        allow(Asimov::ApiV1::Chat).to receive(:post) do
          call_count += 1
          call_count < 2 ? rate_limit_response : success_response
        end

        result = chat.create(model: model, messages: messages)
        expect(result).to eq({ "id" => "chatcmpl-123" })
        expect(call_count).to eq(2)
      end

      it "retries on ApiOverloadedError and succeeds" do
        call_count = 0
        allow(Asimov::ApiV1::Chat).to receive(:post) do
          call_count += 1
          call_count < 2 ? overloaded_response : success_response
        end

        result = chat.create(model: model, messages: messages)
        expect(result).to eq({ "id" => "chatcmpl-123" })
        expect(call_count).to eq(2)
      end

      it "retries on ServiceUnavailableError and succeeds" do
        call_count = 0
        allow(Asimov::ApiV1::Chat).to receive(:post) do
          call_count += 1
          call_count < 2 ? service_unavailable_response : success_response
        end

        result = chat.create(model: model, messages: messages)
        expect(result).to eq({ "id" => "chatcmpl-123" })
        expect(call_count).to eq(2)
      end

      it "does not retry on QuotaExceededError" do
        allow(Asimov::ApiV1::Chat).to receive(:post).and_return(quota_response)
        expect do
          chat.create(model: model, messages: messages)
        end.to raise_error(Asimov::QuotaExceededError)
        expect(Asimov::ApiV1::Chat).to have_received(:post).once
      end

      it "raises after exhausting retries" do
        allow(Asimov::ApiV1::Chat).to receive(:post).and_return(rate_limit_response)
        expect do
          chat.create(model: model, messages: messages)
        end.to raise_error(Asimov::RateLimitError)
      end
    end
  end

  describe "backoff_delay" do
    let(:retryable_instance) { chat }

    it "caps the backoff delay at MAX_BACKOFF" do
      delay = retryable_instance.send(:backoff_delay, 10)
      expect(delay).to eq(60)
    end

    it "uses exponential backoff for small attempt numbers" do
      delay = retryable_instance.send(:backoff_delay, 1)
      # 2^1 = 2, plus rand(0.0..0.5), so between 2.0 and 2.5
      expect(delay).to be_between(2.0, 2.5)
    end
  end
end
