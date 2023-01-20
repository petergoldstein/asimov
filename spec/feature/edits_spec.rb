require_relative "../spec_helper"

RSpec.describe "Edits API", type: :feature do
  describe "#create", :vcr do
    let(:input) { "What day of the wek is it?" }
    let(:instruction) { "Fix the spelling mistakes" }
    let(:cassette) { "#{model} edits #{input}".downcase }
    let(:response) do
      Asimov::Client.new.edits.create(
        model: model,
        instruction: instruction,
        parameters: {
          input: input
        }
      )
    end

    context "with model: text-davinci-edit-001" do
      let(:model) { "text-davinci-edit-001" }

      it "edits the input" do
        VCR.use_cassette(cassette) do
          expect(response.dig("choices", 0, "text")).to include("What day of the week is it?")
        end
      end
    end
  end
end
