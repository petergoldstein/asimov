require_relative "../spec_helper"

RSpec.describe "Completions API", type: :feature do
  context "when using GPT3 models" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "Once upon a time" }
      let(:max_tokens) { 5 }

      let(:response) do
        Asimov::Client.new.completions.create(
          model: model,
          parameters: {
            prompt: prompt,
            max_tokens: max_tokens
          }
        )
      end
      let(:text) { response["choices"][0]["text"] }
      let(:cassette) { "#{model} completions #{prompt}".downcase }

      context "with model: text-ada-001" do
        let(:model) { "text-ada-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to be(false)
          end
        end
      end

      context "with model: text-babbage-001" do
        let(:model) { "text-babbage-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to be(false)
          end
        end
      end

      context "with model: text-curie-001" do
        let(:model) { "text-curie-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to be(false)
          end
        end
      end

      context "with model: text-davinci-001" do
        let(:model) { "text-davinci-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to be(false)
          end
        end
      end
    end
  end

  context "when using Codex models" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "def hello_world\nputs" }
      let(:max_tokens) { 5 }

      let(:response) do
        Asimov::Client.new.completions.create(
          model: model,
          parameters: {
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

  context "when expected to generate an error" do
    context "when passed a stream = true parameter", :vcr do
      let(:prompt) { "Once upon a time" }
      let(:model) { "text-ada-001" }
      let(:max_tokens) { 5 }
      let(:client) { Asimov::Client.new }
      let(:parameters) do
        {
          prompt: prompt,
          stream: true
        }
      end

      it "raises the expected error" do
        expect do
          client.completions.create(model: model, parameters: parameters)
        end.to raise_error(Asimov::StreamingResponseNotSupportedError)
      end
    end
  end
end
