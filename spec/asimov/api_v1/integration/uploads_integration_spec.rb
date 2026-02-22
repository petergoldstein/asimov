require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::Uploads, type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:uploads) { client.uploads }
  let(:base_url) { "https://api.openai.com/v1/uploads" }

  describe "#create" do
    it "returns parsed response on success" do
      body = { "id" => "upload_abc123", "object" => "upload", "status" => "pending" }
      stub_request(:post, base_url).to_return(status: 200, body: body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      result = uploads.create(
        filename: "training.jsonl", purpose: "fine-tune",
        bytes: 2_147_483_648, mime_type: "application/jsonl"
      )
      expect(result["id"]).to eq("upload_abc123")
      expect(result["status"]).to eq("pending")
    end
  end

  describe "#complete" do
    it "returns parsed response on success" do
      body = { "id" => "upload_abc123", "status" => "completed",
               "file" => { "id" => "file-xyz789" } }
      stub_request(:post, "#{base_url}/upload_abc123/complete")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = uploads.complete(upload_id: "upload_abc123", part_ids: %w[part_1 part_2])
      expect(result["status"]).to eq("completed")
      expect(result["file"]["id"]).to eq("file-xyz789")
    end

    it "raises RateLimitError on 429" do
      error_body = { "error" => { "message" => "Rate limit reached" } }
      stub_request(:post, "#{base_url}/upload_abc123/complete")
        .to_return(status: 429, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        uploads.complete(upload_id: "upload_abc123", part_ids: %w[part_1])
      end.to raise_error(Asimov::RateLimitError)
    end
  end

  describe "#cancel" do
    it "returns parsed response on success" do
      body = { "id" => "upload_abc123", "status" => "cancelled" }
      stub_request(:post, "#{base_url}/upload_abc123/cancel")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = uploads.cancel(upload_id: "upload_abc123")
      expect(result["status"]).to eq("cancelled")
    end

    it "raises NotFoundError on 404" do
      error_body = { "error" => { "message" => "No upload found" } }
      stub_request(:post, "#{base_url}/upload_nonexistent/cancel")
        .to_return(status: 404, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        uploads.cancel(upload_id: "upload_nonexistent")
      end.to raise_error(Asimov::NotFoundError)
    end
  end
end
