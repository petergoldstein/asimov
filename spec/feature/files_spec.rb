require_relative "../spec_helper"
require "tempfile"

RSpec.describe "Files API", type: :feature do
  describe "file upload, list, retrieve, and delete", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { Utils.fixture_filename(filename: filename) }

    let(:upload_cassette) { "files integration" }
    let(:purpose) { "fine-tune" }
    let(:client) { Asimov::Client.new }

    it "runs through a basic upload, list, retrieve, and delete" do
      VCR.use_cassette("successful file upload and delete") do
        # Upload a file
        r = client.files.upload(parameters: { file: file, purpose: purpose })
        expect(r["filename"]).to eq(filename)

        # Capture the uploaded file.
        file_id = r["id"]

        # List files and check the uploaded file is included
        r = client.files.list
        expect(r["data"].size).not_to eq(0)
        expect(r["data"].map { |e| e["filename"] }).to include(filename)

        # Retrieve the file that was uploaded
        r = client.files.retrieve(file_id: file_id)
        expect(r["filename"]).to eq(filename)

        # Give the file time to process if running against the real API
        sleep 2 if ENV["RUN_LIVE"]

        # Download the uploaded file using the content endpoint
        downloaded_file = Tempfile.new
        expect do
          client.files.content(file_id: file_id, writer: downloaded_file)
        end.not_to raise_error
        downloaded_file.flush

        # Compare the original file and the downloaded one and confirm they match
        original_file_lines = File.open(file).readlines
        downloaded_file_lines = File.open(downloaded_file.path).readlines
        expect(original_file_lines.size).to eq(downloaded_file_lines.size)
        original_file_lines.each_with_index do |l, idx|
          expect(l).to eq(downloaded_file_lines[idx])
        end

        downloaded_file.unlink

        # Delete the file that was uploaded
        r = client.files.delete(file_id: file_id)
        expect(r["id"]).to eq(file_id)
        expect(r["deleted"]).to be(true)
      end
    end
  end

  describe "deleting a file that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("files delete with non-existent id") do
        expect do
          client.files.delete(file_id: "nosuchfile")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end

  describe "retrieving a file that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("files retrieve with non-existent id") do
        expect do
          client.files.retrieve(file_id: "nosuchfile")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end
end
