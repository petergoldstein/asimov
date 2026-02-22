require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::ApiErrorTranslator do
  let(:resp) do
    r = instance_double(HTTParty::Response)
    allow(r).to receive_messages(code: code, parsed_response: parsed_response)
    r
  end

  let(:parsed_response) do
    {
      "error" => {
        "message" => message
      }
    }
  end

  context "when the response is a 400" do
    let(:code) { 400 }

    context "when the message is unknown" do
      let(:message) { SecureRandom.hex(20) }

      it "raises an Asimov::RequestError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::RequestError)
      end
    end
  end

  context "when the response is a 401" do
    let(:code) { 401 }

    context "when the message is unknown" do
      let(:message) { SecureRandom.hex(20) }

      it "raises an Asimov::AuthorizationError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::AuthorizationError)
      end
    end
  end

  context "when the response is a 409" do
    let(:code) { 409 }

    context "when the message is unknown" do
      let(:message) { SecureRandom.hex(20) }

      it "raises an Asimov::RequestError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::RequestError)
      end
    end
  end

  context "when the response is a 429" do
    let(:code) { 429 }

    context "when the message is about your quota" do
      let(:message) do
        "You exceeded your current quota, please check your plan and billing details."
      end

      it "raises an Asimov::QuotaExceededError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::QuotaExceededError)
      end
    end

    context "when the error code is insufficient_quota" do
      let(:parsed_response) do
        { "error" => { "message" => "Some new message", "code" => "insufficient_quota" } }
      end

      it "raises an Asimov::QuotaExceededError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::QuotaExceededError)
      end
    end

    context "when the message is about your message rate" do
      let(:message) { "Rate limit reached for requests" }

      it "raises an Asimov::RateLimitError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::RateLimitError)
      end
    end

    context "when the error code is rate_limit_exceeded" do
      let(:parsed_response) do
        { "error" => { "message" => "Some new message", "code" => "rate_limit_exceeded" } }
      end

      it "raises an Asimov::RateLimitError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::RateLimitError)
      end
    end

    context "when the message is about the engine" do
      let(:message) { "The engine is currently overloaded" }

      it "raises an Asimov::ApiOverloadedError error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::ApiOverloadedError)
      end
    end

    context "when the message is unknown" do
      let(:message) { SecureRandom.hex(20) }

      it "raises an Asimov::TooManyRequests error" do
        expect do
          described_class.translate(resp)
        end.to raise_error(Asimov::TooManyRequestsError)
      end
    end
  end

  context "when the response body is not JSON" do
    let(:code) { 500 }
    let(:resp) do
      r = instance_double(HTTParty::Response)
      allow(r).to receive_messages(code: code, parsed_response: "<html>Bad Gateway</html>")
      r
    end

    it "raises an error with an empty message" do
      expect do
        described_class.translate(resp)
      end.to raise_error(Asimov::ServerError, "")
    end
  end

  context "when the response is a raw string that is not JSON" do
    it "returns an empty message without raising JSON::ParserError" do
      fragment = "not json at all"
      allow(fragment).to receive(:code).and_return(500)
      expect do
        described_class.translate(fragment)
      end.to raise_error(Asimov::ServerError, "")
    end
  end
end
