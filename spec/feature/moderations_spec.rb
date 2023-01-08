require_relative "../spec_helper"

RSpec.describe "Moderations API", type: :feature do
  describe "do a basic moderations check", :vcr do
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

  describe "including an invalid value for model", :vcr do
    let(:input) { "I'm worried about that." }
    let(:model) { "not_a_valid_model" }
    let(:client) { Asimov::Client.new }

    it "returns the expected error" do
      VCR.use_cassette("moderation with invalid model") do
        expect do
          client.moderations.create(parameters: { input: input, model: model })
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "including an extra parameter", :vcr do
    let(:input) { "I'm worried about that." }
    let(:client) { Asimov::Client.new }

    it "ignores the extra parameter" do
      VCR.use_cassette("moderation with extra unsupported parameter") do
        r = client.moderations.create(parameters: { input: input, notaparameter: "notavalue" })
        expect(r.dig("results", 0, "categories", "hate")).to be(false)
      end
    end
  end
end
