require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::Chat, "streaming", type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:chat) { client.chat }
  let(:base_url) { "https://api.openai.com/v1/chat/completions" }
  let(:model) { "gpt-4o" }
  let(:messages) { [{ "role" => "user", "content" => "hello" }] }

  describe "SSE streaming via Chat#create with block" do
    it "yields parsed chunks and excludes [DONE]" do
      chunk1 = { "id" => "chatcmpl-1", "choices" => [{ "delta" => { "content" => "Hello" } }] }
      chunk2 = { "id" => "chatcmpl-1", "choices" => [{ "delta" => { "content" => " world" } }] }

      sse_body = <<~SSE
        data: #{chunk1.to_json}

        data: #{chunk2.to_json}

        data: [DONE]

      SSE

      stub_request(:post, base_url).to_return(
        status: 200,
        body: sse_body,
        headers: { "Content-Type" => "text/event-stream" }
      )

      chunks = []
      chat.create(model: model, messages: messages) { |chunk| chunks << chunk }

      expect(chunks.length).to eq(2)
      expect(chunks[0]["choices"][0]["delta"]["content"]).to eq("Hello")
      expect(chunks[1]["choices"][0]["delta"]["content"]).to eq(" world")
    end

    it "yields no chunks when response is only [DONE]" do
      sse_body = "data: [DONE]\n\n"

      stub_request(:post, base_url).to_return(
        status: 200,
        body: sse_body,
        headers: { "Content-Type" => "text/event-stream" }
      )

      chunks = []
      chat.create(model: model, messages: messages) { |chunk| chunks << chunk }

      expect(chunks).to be_empty
    end

    it "treats [DONE] with trailing whitespace as a done marker" do
      chunk1 = { "id" => "chatcmpl-1", "choices" => [{ "delta" => { "content" => "Hi" } }] }

      sse_body = <<~SSE
        data: #{chunk1.to_json}

        data: [DONE]   \t

      SSE

      stub_request(:post, base_url).to_return(
        status: 200,
        body: sse_body,
        headers: { "Content-Type" => "text/event-stream" }
      )

      chunks = []
      chat.create(model: model, messages: messages) { |chunk| chunks << chunk }

      expect(chunks.length).to eq(1)
      expect(chunks[0]["choices"][0]["delta"]["content"]).to eq("Hi")
    end

    it "skips malformed JSON chunks and continues streaming" do
      chunk1 = { "id" => "chatcmpl-1", "choices" => [{ "delta" => { "content" => "Hello" } }] }
      chunk3 = { "id" => "chatcmpl-1", "choices" => [{ "delta" => { "content" => " world" } }] }

      sse_body = <<~SSE
        data: #{chunk1.to_json}

        data: {not valid json

        data: #{chunk3.to_json}

        data: [DONE]

      SSE

      stub_request(:post, base_url).to_return(
        status: 200,
        body: sse_body,
        headers: { "Content-Type" => "text/event-stream" }
      )

      chunks = []
      chat.create(model: model, messages: messages) { |chunk| chunks << chunk }

      expect(chunks.length).to eq(2)
      expect(chunks[0]["choices"][0]["delta"]["content"]).to eq("Hello")
      expect(chunks[1]["choices"][0]["delta"]["content"]).to eq(" world")
    end
  end
end
