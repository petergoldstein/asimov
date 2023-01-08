require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::JsonlValidator do
  describe ".validate" do
    let(:valid_file) { File.open(Utils.fixture_filename(filename: "puppy.jsonl")) }
    let(:invalid_file) { File.open(Utils.fixture_filename(filename: "errors/missing_quote.jsonl")) }
    let(:png_file) { File.open(Utils.fixture_filename(filename: "image.png")) }

    it "validates a valid JSONL file" do
      expect(described_class.validate(valid_file)).to be(true)
    end

    it "raises an error for a invalid JSONL file" do
      expect do
        described_class.validate(invalid_file)
      end.to raise_error(Asimov::JsonlFileCannotBeParsedError)
    end

    it "raises an error for a PNG file" do
      expect do
        described_class.validate(png_file)
      end.to raise_error(Asimov::JsonlFileCannotBeParsedError)
    end
  end
end
