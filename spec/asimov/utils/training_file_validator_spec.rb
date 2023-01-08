require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::TrainingFileValidator do
  describe ".validate" do
    subject(:instance) { described_class.new }

    let(:training_file) do
      File.open(Utils.fixture_filename(filename: "sentiment.jsonl"))
    end

    let(:classification_file) do
      File.open(Utils.fixture_filename(filename: "classification.jsonl"))
    end
    let(:text_entry_with_metadata_file) do
      File.open(Utils.fixture_filename(filename: "text_entry_with_metadata.jsonl"))
    end
    let(:text_entry_with_no_metadata_file) do
      File.open(Utils.fixture_filename(filename: "text_entry_with_no_metadata.jsonl"))
    end
    let(:invalid_file) do
      File.open(Utils.fixture_filename(filename: "errors/training_missing_quote.jsonl"))
    end
    let(:png_file) { File.open(Utils.fixture_filename(filename: "image.png")) }

    it "validates a training_file" do
      expect(instance.validate(training_file)).to be(true)
    end

    it "raises an error for a valid JSONL file that stores text entries without metadata" do
      expect do
        instance.validate(text_entry_with_no_metadata_file)
      end.to raise_error(Asimov::InvalidTrainingExampleError)
    end

    it "raises an error for a valid JSONL file that stores text entries with metadata" do
      expect do
        instance.validate(text_entry_with_metadata_file)
      end.to raise_error(Asimov::InvalidTrainingExampleError)
    end

    it "raises an error for a valid JSONL file that stores classification data" do
      expect do
        instance.validate(classification_file)
      end.to raise_error(Asimov::InvalidTrainingExampleError)
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
