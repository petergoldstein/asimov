require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::Conversations, type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:conversations) { client.conversations }
  let(:base_url) { "https://api.openai.com/v1/conversations" }

  describe "#list" do
    it "returns list of conversations" do
      body = { "object" => "list", "data" => [{ "id" => "conv_1" }, { "id" => "conv_2" }] }
      stub_request(:get, base_url)
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = conversations.list
      expect(result["data"].length).to eq(2)
    end

    it "raises RateLimitError on 429" do
      error_body = { "error" => { "message" => "Rate limit reached" } }
      stub_request(:get, base_url)
        .to_return(status: 429, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        conversations.list
      end.to raise_error(Asimov::RateLimitError)
    end
  end

  describe "#retrieve" do
    it "returns parsed response on success" do
      body = { "id" => "conv_abc123", "object" => "conversation" }
      stub_request(:get, "#{base_url}/conv_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = conversations.retrieve(conversation_id: "conv_abc123")
      expect(result["id"]).to eq("conv_abc123")
    end

    it "raises NotFoundError on 404" do
      error_body = { "error" => { "message" => "No conversation found" } }
      stub_request(:get, "#{base_url}/conv_nonexistent")
        .to_return(status: 404, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        conversations.retrieve(conversation_id: "conv_nonexistent")
      end.to raise_error(Asimov::NotFoundError)
    end
  end

  describe "#delete" do
    it "returns parsed response on success" do
      body = { "id" => "conv_abc123", "deleted" => true }
      stub_request(:delete, "#{base_url}/conv_abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = conversations.delete(conversation_id: "conv_abc123")
      expect(result["deleted"]).to be true
    end
  end
end
