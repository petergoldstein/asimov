require_relative "../spec_helper"

RSpec.describe "Chat Completions API", type: :feature do
  context "when using GPT3 models" do
    let(:model) { "gpt-3.5-turbo" }

    context "with a basic request", :vcr do
      let(:messages) { [{ role: "user", content: "Hello!" }] }

      let(:response) do
        Asimov::Client.new.chat.create(
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
end
