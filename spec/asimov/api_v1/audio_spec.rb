require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Audio do
  subject(:audio) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "audio" }
  let(:voice_consents_resource) { %w[audio voice_consents] }

  it_behaves_like "sends requests to the v1 API"

  describe "#create_transcription" do
    context "when the required file parameter is present" do
      let(:audio_filename) { SecureRandom.hex(4) }
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      context "when the model parameter is present" do
        let(:model) { SecureRandom.hex(4) }
        let(:merged_params) do
          parameters.merge({ file: audio_file, model: model })
        end

        context "when the audio file can be loaded" do
          let(:audio_file) { instance_double(File) }

          before do
            allow(File).to receive(:open).with(audio_filename).and_return(audio_file)
          end

          after do
            expect(File).to have_received(:open).with(audio_filename)
          end

          it "calls rest_create_w_multipart_params on the client with the expected arguments" do
            allow(audio).to receive(:rest_create_w_multipart_params)
              .with(resource: [resource, "transcriptions"],
                    parameters: merged_params)
              .and_return(ret_val)
            expect(audio.create_transcription(model: model, file: audio_filename,
                                              parameters: parameters)).to eq(ret_val)
            expect(audio).to have_received(:rest_create_w_multipart_params)
              .with(resource: [resource, "transcriptions"],
                    parameters: merged_params)
          end
        end

        context "when the audio file cannot be loaded" do
          before do
            allow(File).to receive(:open).with(audio_filename).and_raise(Errno::ENOENT)
          end

          after do
            expect(File).to have_received(:open).with(audio_filename)
          end

          it "reraises the underlying error" do
            expect do
              audio.create_transcription(model: model, file: audio_filename)
            end.to raise_error(Asimov::FileCannotBeOpenedError)
          end
        end
      end

      context "when the model parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            audio.create_transcription(model: nil, file: audio_filename, parameters: parameters)
          end.to raise_error(Asimov::MissingRequiredParameterError)
        end
      end
    end

    context "when the required file parameter is missing" do
      let(:model) { SecureRandom.hex(4) }

      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_transcription(model: model, file: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)

        expect do
          audio.create_transcription(model: model, file: nil, parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#create_translation" do
    context "when the required file parameter is present" do
      let(:audio_filename) { SecureRandom.hex(4) }
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      context "when the model parameter is present" do
        let(:model) { SecureRandom.hex(4) }
        let(:merged_params) do
          parameters.merge({ file: audio_file, model: model })
        end

        context "when the audio file can be loaded" do
          let(:audio_file) { instance_double(File) }

          before do
            allow(File).to receive(:open).with(audio_filename).and_return(audio_file)
          end

          after do
            expect(File).to have_received(:open).with(audio_filename)
          end

          it "calls rest_create_w_multipart_params on the client with the expected arguments" do
            allow(audio).to receive(:rest_create_w_multipart_params)
              .with(resource: [resource, "translations"],
                    parameters: merged_params)
              .and_return(ret_val)
            expect(audio.create_translation(model: model, file: audio_filename,
                                            parameters: parameters)).to eq(ret_val)
            expect(audio).to have_received(:rest_create_w_multipart_params)
              .with(resource: [resource, "translations"],
                    parameters: merged_params)
          end
        end

        context "when the audio file cannot be loaded" do
          before do
            allow(File).to receive(:open).with(audio_filename).and_raise(Errno::ENOENT)
          end

          after do
            expect(File).to have_received(:open).with(audio_filename)
          end

          it "reraises the underlying error" do
            expect do
              audio.create_translation(model: model, file: audio_filename)
            end.to raise_error(Asimov::FileCannotBeOpenedError)
          end
        end
      end

      context "when the model parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            audio.create_translation(model: nil, file: audio_filename, parameters: parameters)
          end.to raise_error(Asimov::MissingRequiredParameterError)
        end
      end
    end

    context "when the required file parameter is missing" do
      let(:model) { SecureRandom.hex(4) }

      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_translation(model: model, file: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)

        expect do
          audio.create_translation(model: model, file: nil, parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#create_speech" do
    let(:model) { "tts-1" }
    let(:input) { "Hello world" }
    let(:voice) { "alloy" }
    let(:merged_params) { parameters.merge(model: model, input: input, voice: voice) }

    context "when all required parameters are present" do
      context "without a writer (returns binary)" do
        it "calls rest_create_w_json_params_binary" do
          allow(audio).to receive(:rest_create_w_json_params_binary)
            .with(resource: [resource, "speech"], parameters: merged_params)
            .and_return(ret_val)
          expect(audio.create_speech(model: model, input: input, voice: voice,
                                     parameters: parameters)).to eq(ret_val)
        end
      end

      context "with a writer (streams binary)" do
        let(:writer) { instance_double(File) }

        it "calls rest_create_w_json_params_streamed_download" do
          allow(audio).to receive(:rest_create_w_json_params_streamed_download)
            .with(resource: [resource, "speech"], parameters: merged_params, writer: writer)
            .and_return(ret_val)
          expect(audio.create_speech(model: model, input: input, voice: voice,
                                     writer: writer, parameters: parameters)).to eq(ret_val)
        end
      end
    end

    context "when model is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_speech(model: nil, input: input, voice: voice)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when input is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_speech(model: model, input: nil, voice: voice)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when voice is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_speech(model: model, input: input, voice: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#create_voice" do
    let(:name) { SecureRandom.hex(4) }
    let(:consent) { "vc_#{SecureRandom.hex(4)}" }
    let(:audio_sample_filename) { SecureRandom.hex(4) }

    context "when all required parameters are present" do
      let(:audio_sample_file) { instance_double(File) }
      let(:merged_params) do
        parameters.merge(name: name, consent: consent, audio_sample: audio_sample_file)
      end

      context "when the audio sample can be loaded" do
        before do
          allow(File).to receive(:open).with(audio_sample_filename).and_return(audio_sample_file)
        end

        after do
          expect(File).to have_received(:open).with(audio_sample_filename)
        end

        it "calls rest_create_w_multipart_params with the expected arguments" do
          allow(audio).to receive(:rest_create_w_multipart_params)
            .with(resource: [resource, "voices"], parameters: merged_params)
            .and_return(ret_val)
          expect(audio.create_voice(name: name, consent: consent,
                                    audio_sample: audio_sample_filename,
                                    parameters: parameters)).to eq(ret_val)
        end
      end

      context "when the audio sample cannot be loaded" do
        before do
          allow(File).to receive(:open).with(audio_sample_filename).and_raise(Errno::ENOENT)
        end

        it "raises a FileCannotBeOpenedError" do
          expect do
            audio.create_voice(name: name, consent: consent,
                               audio_sample: audio_sample_filename)
          end.to raise_error(Asimov::FileCannotBeOpenedError)
        end
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_voice(name: nil, consent: consent, audio_sample: audio_sample_filename)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when consent is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_voice(name: name, consent: nil, audio_sample: audio_sample_filename)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when audio_sample is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_voice(name: name, consent: consent, audio_sample: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#create_voice_consent" do
    let(:name) { SecureRandom.hex(4) }
    let(:language) { "en" }
    let(:recording_filename) { SecureRandom.hex(4) }

    context "when all required parameters are present" do
      let(:recording_file) { instance_double(File) }
      let(:merged_params) do
        parameters.merge(name: name, language: language, recording: recording_file)
      end

      context "when the recording can be loaded" do
        before do
          allow(File).to receive(:open).with(recording_filename).and_return(recording_file)
        end

        after do
          expect(File).to have_received(:open).with(recording_filename)
        end

        it "calls rest_create_w_multipart_params with the expected arguments" do
          allow(audio).to receive(:rest_create_w_multipart_params)
            .with(resource: voice_consents_resource, parameters: merged_params)
            .and_return(ret_val)
          expect(audio.create_voice_consent(name: name, language: language,
                                            recording: recording_filename,
                                            parameters: parameters)).to eq(ret_val)
        end
      end

      context "when the recording cannot be loaded" do
        before do
          allow(File).to receive(:open).with(recording_filename).and_raise(Errno::ENOENT)
        end

        it "raises a FileCannotBeOpenedError" do
          expect do
            audio.create_voice_consent(name: name, language: language,
                                       recording: recording_filename)
          end.to raise_error(Asimov::FileCannotBeOpenedError)
        end
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_voice_consent(name: nil, language: language,
                                     recording: recording_filename)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when language is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_voice_consent(name: name, language: nil,
                                     recording: recording_filename)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when recording is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.create_voice_consent(name: name, language: language, recording: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_voice_consents" do
    it "calls rest_index with the expected arguments" do
      allow(audio).to receive(:rest_index)
        .with(resource: voice_consents_resource, parameters: {})
        .and_return(ret_val)
      expect(audio.list_voice_consents).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "vc_abc123", limit: 20 }
      allow(audio).to receive(:rest_index)
        .with(resource: voice_consents_resource, parameters: pagination)
        .and_return(ret_val)
      expect(audio.list_voice_consents(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve_voice_consent" do
    let(:consent_id) { "vc_#{SecureRandom.hex(4)}" }

    context "when consent_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.retrieve_voice_consent(consent_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(audio).to receive(:rest_get)
        .with(resource: "audio/voice_consents", id: consent_id)
        .and_return(ret_val)
      expect(audio.retrieve_voice_consent(consent_id: consent_id)).to eq(ret_val)
    end
  end

  describe "#update_voice_consent" do
    let(:consent_id) { "vc_#{SecureRandom.hex(4)}" }
    let(:name) { SecureRandom.hex(4) }

    context "when consent_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.update_voice_consent(consent_id: nil, name: name)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when name is present" do
      let(:merged_params) { parameters.merge(name: name) }

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(audio).to receive(:rest_create_w_json_params)
          .with(resource: voice_consents_resource + [consent_id], parameters: merged_params)
          .and_return(ret_val)
        expect(audio.update_voice_consent(consent_id: consent_id, name: name,
                                          parameters: parameters)).to eq(ret_val)
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.update_voice_consent(consent_id: consent_id, name: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#delete_voice_consent" do
    let(:consent_id) { "vc_#{SecureRandom.hex(4)}" }

    context "when consent_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          audio.delete_voice_consent(consent_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(audio).to receive(:rest_delete)
        .with(resource: "audio/voice_consents", id: consent_id)
        .and_return(ret_val)
      expect(audio.delete_voice_consent(consent_id: consent_id)).to eq(ret_val)
    end
  end
end
