require_relative "../../spec_helper"

RSpec.describe "Completions API using codex models", type: :feature do
  context "with a prompt and max_tokens", :vcr do
    let(:prompt) { "def hello_world\nputs" }
    let(:max_tokens) { 5 }

    let(:response) do
      Asimov::Client.new.completions.create(
        parameters: {
          model: model,
          prompt: prompt,
          max_tokens: max_tokens
        }
      )
    end
    let(:text) { response["choices"][0]["text"] }
    let(:cassette) { "#{model} completions #{prompt}".downcase }

    context "with model: davinci-codex" do
      let(:model) { "davinci-codex" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(text.split.empty?).to be(false)
        end
      end
    end

    context "with model: cushman-codex" do
      let(:model) { "cushman-codex" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(text.split.empty?).to be(false)
        end
      end
    end
  end
end