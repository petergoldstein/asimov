require_relative "../spec_helper"

RSpec.describe "Chat Completions API", type: :feature do
  context "when using GPT3 models" do
    let(:model) { "gpt-3.5-turbo" }

    context "with a basic request", :vcr do
      let(:messages) { [{ role: "user", content: "Hello!" }] }

      let(:response) do
        Asimov::Client.new.chat.create_completions(
          model: model,
          messages: messages
        )
      end
      let(:cassette) { "chat_completions_#{model}_basic".downcase }
      let(:choices) { response["choices"] }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(choices.empty?).to be(false)
        end
      end
    end
  end

  context "when expected to generate an error" do
    context "when passed a stream = true parameter", :vcr do
      let(:model) { "gpt-3.5-turbo" }
      let(:messages) { [{ role: "user", content: "Hello!" }] }

      let(:parameters) { { stream: true } }
      let(:cassette) { "chat_completions_#{model}_stream_error".downcase }

      it "raises the expected error" do
        expect do
          Asimov::Client.new.chat.create_completions(
            model: model,
            messages: messages,
            parameters: parameters
          )
        end.to raise_error(Asimov::StreamingResponseNotSupportedError)
      end
    end
  end
end
