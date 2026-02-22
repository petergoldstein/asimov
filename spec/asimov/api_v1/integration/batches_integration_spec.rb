require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::Batches, type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:batches) { client.batches }
  let(:base_url) { "https://api.openai.com/v1/batches" }

  describe "#create" do
    it "returns parsed response on success" do
      body = { "id" => "batch_abc123", "object" => "batch", "status" => "validating" }
      stub_request(:post, base_url).to_return(status: 200, body: body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      result = batches.create(
        input_file_id: "file-abc123",
        endpoint: "/v1/chat/completions",
        completion_window: "24h"
      )
      expect(result["id"]).to eq("batch_abc123")
      expect(result["status"]).to eq("validating")
    end

    it "raises RateLimitError on 429" do
      error_body = { "error" => { "message" => "Rate limit reached" } }
      stub_request(:post, base_url).to_return(status: 429, body: error_body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      expect do
        batches.create(
          input_file_id: "file-abc123",
          endpoint: "/v1/chat/completions",
          completion_window: "24h"
        )
      end.to raise_error(Asimov::RateLimitError)
    end
  end

  describe "#retrieve" do
    it "returns parsed response on success" do
      body = { "id" => "batch_abc123", "object" => "batch", "status" => "completed" }
      stub_request(:get, "#{base_url}/batch_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = batches.retrieve(batch_id: "batch_abc123")
      expect(result["id"]).to eq("batch_abc123")
    end

    it "raises NotFoundError on 404" do
      error_body = { "error" => { "message" => "No batch found" } }
      stub_request(:get, "#{base_url}/batch_nonexistent")
        .to_return(status: 404, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        batches.retrieve(batch_id: "batch_nonexistent")
      end.to raise_error(Asimov::NotFoundError)
    end
  end

  describe "#list" do
    it "returns list of batches" do
      body = { "object" => "list", "data" => [{ "id" => "batch_1" }] }
      stub_request(:get, base_url)
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = batches.list
      expect(result["data"].length).to eq(1)
    end
  end
end
