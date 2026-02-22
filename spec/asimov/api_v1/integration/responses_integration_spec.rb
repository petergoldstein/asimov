require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::Responses, type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:responses) { client.responses }
  let(:base_url) { "https://api.openai.com/v1/responses" }

  describe "#create" do
    it "returns parsed response on success" do
      body = { "id" => "resp_abc123", "object" => "response",
               "output" => [{ "type" => "message", "content" => [{ "text" => "Hello!" }] }] }
      stub_request(:post, base_url).to_return(status: 200, body: body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      result = responses.create(model: "gpt-4o", input: "Hi")
      expect(result["id"]).to eq("resp_abc123")
      expect(result["output"].first["type"]).to eq("message")
    end

    it "raises RateLimitError on 429 with rate limit message" do
      error_body = { "error" => { "message" => "Rate limit reached for model" } }
      stub_request(:post, base_url).to_return(status: 429, body: error_body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      expect do
        responses.create(model: "gpt-4o", input: "Hi")
      end.to raise_error(Asimov::RateLimitError)
    end
  end

  describe "#retrieve" do
    it "returns parsed response on success" do
      body = { "id" => "resp_abc123", "object" => "response" }
      stub_request(:get, "#{base_url}/resp_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = responses.retrieve(response_id: "resp_abc123")
      expect(result["id"]).to eq("resp_abc123")
    end

    it "raises NotFoundError on 404" do
      error_body = { "error" => { "message" => "No response found" } }
      stub_request(:get, "#{base_url}/resp_nonexistent")
        .to_return(status: 404, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        responses.retrieve(response_id: "resp_nonexistent")
      end.to raise_error(Asimov::NotFoundError)
    end
  end

  describe "#delete" do
    it "returns parsed response on success" do
      body = { "id" => "resp_abc123", "object" => "response", "deleted" => true }
      stub_request(:delete, "#{base_url}/resp_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = responses.delete(response_id: "resp_abc123")
      expect(result["deleted"]).to be true
    end
  end
end
