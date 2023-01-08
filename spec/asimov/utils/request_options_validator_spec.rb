require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::RequestOptionsValidator do
  describe ".validate" do
    it "validates an empty hash" do
      expect(described_class.validate({})).to eq({})
    end

    it "raises an error when passed a non-hash" do
      expect do
        described_class.validate(SecureRandom.hex(5))
      end.to raise_error(Asimov::ConfigurationError)
    end

    context "when one of the keys is a string" do
      let(:base_options) do
        {
          read_timeout: 1234,
          write_timeout: 5678
        }
      end

      let(:options_with_sym) { base_options.merge({ open_timeout: 9876 }) }
      let(:options_with_string) { base_options.merge({ "open_timeout" => 9876 }) }

      it "requires that options be symbols" do
        expect(described_class.validate(options_with_sym)).to eq(options_with_sym)

        expect do
          described_class.validate(options_with_string)
        end.to raise_error(Asimov::ConfigurationError)
      end
    end

    context "with unsupported keys" do
      let(:supported_keys) { described_class::ALLOWED_OPTIONS.sample(5) }
      let(:supported_options) do
        supported_keys.each_with_object({}) do |key, hsh|
          hsh[key] = rand(10)
        end
      end
      let(:unsupported_options) do
        supported_options.merge({ SecureRandom.hex(5).to_sym => rand(10) })
      end

      it "raises an error when passed unsupported options" do
        expect do
          described_class.validate(unsupported_options)
        end.to raise_error(Asimov::ConfigurationError)
      end
    end
  end
end
