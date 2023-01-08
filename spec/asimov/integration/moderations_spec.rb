require_relative "../../spec_helper"

RSpec.describe "Moderations API", type: :request do
  describe "#create", :vcr do
    let(:input) { "I'm worried about that." }
    let(:cassette) { "moderations #{input}".downcase }
    let(:response) do
      Asimov::Client.new.moderations.create(
        parameters: {
          input: input
        }
      )
    end

    it "succeeds" do
      VCR.use_cassette(cassette) do
        expect(response.dig("results", 0, "categories", "hate")).to be(false)
      end
    end
  end
end
