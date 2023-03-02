require_relative "../spec_helper"

RSpec.describe "Audio API", type: :feature do
  context "when transcribing", :vcr do
    let(:filename) { "gettysburg_johng_librivox.mp3" }
    let(:file) { Utils.fixture_filename(filename: filename) }

    let(:model) { "whisper-1" }

    let(:response) do
      Asimov::Client.new.audio.create_transcription(
        model: model,
        file: file
      )
    end
    let(:cassette) { "audio_transcription_#{model}_basic".downcase }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          expect(response["text"]).to end_with("shall not perish from the earth.")
        end.not_to raise_error
      end
    end
  end

  context "when translating", :vcr do
    let(:filename) { "barbapapa_german.mp3" }
    let(:file) { Utils.fixture_filename(filename: filename) }

    let(:model) { "whisper-1" }

    let(:response) do
      Asimov::Client.new.audio.create_translation(
        model: model,
        file: file
      )
    end
    let(:cassette) { "audio_translation_#{model}_basic".downcase }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          expect(response["text"]).to start_with("Come to visit us")
        end.not_to raise_error
      end
    end
  end
end
