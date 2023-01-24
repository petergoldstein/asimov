require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::ApiErrorTranslator do
  let(:resp) do
    r = instance_double(HTTParty::Response)
    allow(r).to receive(:code).and_return(code)
    allow(r).to receive(:parsed_response).and_return(parsed_response)
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

    context "when the message is about your message rate" do
      let(:message) { "Rate limit reached for requests" }

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
end
