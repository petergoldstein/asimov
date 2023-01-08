require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::JsonlValidator do
  describe ".validate" do
    subject(:instance) { described_class.new }

    let(:valid_jsonl_file) do
      File.open(Utils.fixture_filename(filename: ["puppy.jsonl", "sentiment.jsonl",
                                                  "classification.jsonl",
                                                  "text_entry_with_metadata.jsonl",
                                                  "text_entry_with_no_metadata.jsonl"].sample))
    end
    let(:invalid_file) do
      File.open(Utils.fixture_filename(filename: "errors/training_missing_quote.jsonl"))
    end
    let(:png_file) { File.open(Utils.fixture_filename(filename: "image.png")) }

    it "validates any valid JSONL file" do
      expect(instance.validate(valid_jsonl_file)).to be(true)
    end

    it "raises an error for a invalid JSONL file" do
      expect do
        instance.validate(invalid_file)
      end.to raise_error(Asimov::JsonlFileCannotBeParsedError)
    end

    it "raises an error for a PNG file" do
      expect do
        instance.validate(png_file)
      end.to raise_error(Asimov::JsonlFileCannotBeParsedError)
    end
  end
end
