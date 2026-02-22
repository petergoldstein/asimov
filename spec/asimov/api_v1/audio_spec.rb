require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Audio do
  subject(:audio) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "audio" }

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
end
