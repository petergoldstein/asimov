require_relative "../spec_helper"

RSpec.describe "Embeddings API", type: :feature do
  describe "#create", :vcr do
    let(:input) { "The food was delicious and the waiter..." }
    let(:cassette) { "#{model} embeddings #{input}".downcase }
    let(:response) do
      Asimov::Client.new.embeddings.create(
        parameters: {
          model: model,
          input: input
        }
      )
    end

    context "with model: babbage-similarity" do
      let(:model) { "babbage-similarity" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["data"][0]["object"]).to eq("embedding")
        end
      end
    end
  end
end
