require_relative "../spec_helper"

RSpec.describe Asimov::ApiType do
  it "defines the expected API types" do
    expect(described_class::AZURE).to eq("azure")
    expect(described_class::OPEN_AI).to eq("open_ai")
    expect(described_class::AZURE_AD).to eq("azure_ad")

    expect(described_class::DEFAULT).to eq(described_class::OPEN_AI)
  end

  describe ".normalize" do
    it "returns nil for a random value" do
      expect(described_class.normalize(SecureRandom.hex(4))).to be_nil
    end

    it "returns the default value for nil" do
      expect(described_class.normalize(nil)).to eq(described_class::OPEN_AI)
    end

    [described_class::AZURE, described_class::OPEN_AI, described_class::AZURE_AD].each do |t|
      it "returns #{t} for #{t}" do
        expect(described_class.normalize(t)).to eq(t)
      end

      it "returns #{t} for a randomized case of #{t}" do
        expect(described_class.normalize(Utils.randomize_case(t))).to eq(t)
      end
    end

    {
      "openai" => described_class::OPEN_AI,
      "azuread" => described_class::AZURE_AD
    }.each do |als, tgt|
      it "returns #{tgt} for #{als}" do
        expect(described_class.normalize(als)).to eq(tgt)
      end

      it "returns #{tgt} for a randomized case of #{als}" do
        expect(described_class.normalize(Utils.randomize_case(als))).to eq(tgt)
      end
    end
  end

  describe ".bearer_auth?" do
    it "returns true for OPEN_AI" do
      expect(described_class.bearer_auth?(described_class::OPEN_AI)).to be(true)
    end

    it "returns true for AZURE_AD" do
      expect(described_class.bearer_auth?(described_class::AZURE_AD)).to be(true)
    end

    it "returns false for AZURE" do
      expect(described_class.bearer_auth?(described_class::AZURE)).to be(false)
    end
  end

  describe ".azure?" do
    it "returns false for OPEN_AI" do
      expect(described_class.azure?(described_class::OPEN_AI)).to be(false)
    end

    it "returns true for AZURE_AD" do
      expect(described_class.azure?(described_class::AZURE_AD)).to be(true)
    end

    it "returns true for AZURE" do
      expect(described_class.azure?(described_class::AZURE)).to be(true)
    end
  end
end
