require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::VectorStores, type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:vector_stores) { client.vector_stores }
  let(:base_url) { "https://api.openai.com/v1/vector_stores" }

  describe "#create" do
    it "returns parsed response on success" do
      body = { "id" => "vs_abc123", "object" => "vector_store", "name" => "Test Store" }
      stub_request(:post, base_url).to_return(status: 200, body: body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      result = vector_stores.create(parameters: { name: "Test Store" })
      expect(result["id"]).to eq("vs_abc123")
      expect(result["name"]).to eq("Test Store")
    end
  end

  describe "#retrieve" do
    it "returns parsed response on success" do
      body = { "id" => "vs_abc123", "object" => "vector_store" }
      stub_request(:get, "#{base_url}/vs_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = vector_stores.retrieve(vector_store_id: "vs_abc123")
      expect(result["id"]).to eq("vs_abc123")
    end

    it "raises NotFoundError on 404" do
      error_body = { "error" => { "message" => "No vector store found" } }
      stub_request(:get, "#{base_url}/vs_nonexistent")
        .to_return(status: 404, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        vector_stores.retrieve(vector_store_id: "vs_nonexistent")
      end.to raise_error(Asimov::NotFoundError)
    end
  end

  describe "#delete" do
    it "returns parsed response on success" do
      body = { "id" => "vs_abc123", "deleted" => true }
      stub_request(:delete, "#{base_url}/vs_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = vector_stores.delete(vector_store_id: "vs_abc123")
      expect(result["deleted"]).to be true
    end
  end

  describe "#list" do
    it "returns list of vector stores" do
      body = { "object" => "list", "data" => [{ "id" => "vs_1" }, { "id" => "vs_2" }] }
      stub_request(:get, base_url)
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = vector_stores.list
      expect(result["data"].length).to eq(2)
    end
  end

  describe "#create_file" do
    it "returns parsed response on success" do
      body = { "id" => "file-abc123", "object" => "vector_store.file" }
      stub_request(:post, "#{base_url}/vs_abc123/files")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = vector_stores.create_file(
        vector_store_id: "vs_abc123", file_id: "file-abc123"
      )
      expect(result["id"]).to eq("file-abc123")
    end

    it "raises RateLimitError on 429" do
      error_body = { "error" => { "message" => "Rate limit reached" } }
      stub_request(:post, "#{base_url}/vs_abc123/files")
        .to_return(status: 429, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        vector_stores.create_file(
          vector_store_id: "vs_abc123", file_id: "file-abc123"
        )
      end.to raise_error(Asimov::RateLimitError)
    end
  end
end
