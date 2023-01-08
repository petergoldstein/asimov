require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Files do
  subject(:files) { described_class.new(client: client) }

  let(:client) { instance_double(Asimov::Client) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  describe "#list" do
    let(:path_string) { "/v1/files" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(files.list).to eq(ret_val)
      expect(client).to have_received(:http_get).with(path: path_string)
    end
  end

  describe "#upload" do
    context "when the parameters include a :purpose value" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), purpose: SecureRandom.hex(4) }
      end

      context "when the parameters include a :file value" do
        let(:filename) { SecureRandom.hex(4) }
        let(:file_instance1) { instance_double(File) }
        let(:file_instance2) { instance_double(File) }
        let(:parameters) do
          { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), purpose: SecureRandom.hex(4),
            file: filename }
        end

        context "when the file can be loaded" do
          let(:merged_parameters) { parameters.merge({ file: file_instance2 }) }

          before do
            allow(File).to receive(:open).with(filename).and_return(file_instance1, file_instance2)
            allow(client).to receive(:multipart_post)
              .with(path: "/v1/files",
                    parameters: merged_parameters)
              .and_return(ret_val)
          end

          context "when the file passes JSONL validation" do
            before do
              allow(Asimov::Utils::JsonlValidator).to receive(:validate)
                .with(file_instance1)
                .and_return(true)
            end

            it "runs JSONL validation and passes to the client" do
              val = files.upload(parameters: parameters)
              expect(val).to eq(ret_val)
              expect(Asimov::Utils::JsonlValidator).to have_received(:validate)
                .with(file_instance1)
              expect(client).to have_received(:multipart_post).with(path: "/v1/files",
                                                                    parameters: merged_parameters)
            end
          end

          context "when the file does not pass JSONL validation" do
            before do
              allow(Asimov::Utils::JsonlValidator).to receive(:validate)
                .with(file_instance1)
                .and_raise(Asimov::JsonlFileCannotBeParsedError)
            end

            it "runs JSONL validation and does not pass to the client" do
              expect do
                files.upload(parameters: parameters)
              end.to raise_error(Asimov::JsonlFileCannotBeParsedError)
              expect(Asimov::Utils::JsonlValidator).to have_received(:validate)
                .with(file_instance1)
              expect(client).not_to have_received(:multipart_post).with(anything)
            end
          end
        end

        context "when the file cannot be loaded" do
          before do
            allow(File).to receive(:open).with(filename).and_raise(Errno::ENOENT)
          end

          after do
            expect(File).to have_received(:open).with(filename)
          end

          it "reraises the underlying error" do
            expect do
              files.upload(parameters: parameters)
            end.to raise_error(Asimov::FileCannotBeOpenedError)
          end
        end
      end

      context "when the parameters do not include a :file value" do
        it "raises a MissingRequiredParameterError" do
          expect do
            files.upload(parameters: parameters)
          end.to raise_error(Asimov::MissingRequiredParameterError)
        end
      end
    end

    context "when the parameters do not include a :purpose value" do
      let(:filename) { SecureRandom.hex(4) }
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), file: filename } }

      it "raises an error before calling anything" do
        expect do
          files.upload(parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when the parameters do not include either the :file or :purpose values" do
      it "raises an error before calling anything" do
        expect do
          files.upload(parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve" do
    let(:file_id) { SecureRandom.hex(4) }
    let(:path_string) { "/v1/files/#{file_id}" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(files.retrieve(file_id: file_id)).to eq(ret_val)
      expect(client).to have_received(:http_get).with(path: path_string)
    end
  end

  describe "#content" do
    let(:file_id) { SecureRandom.hex(4) }
    let(:path_string) { "/v1/files/#{file_id}/content" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(files.content(file_id: file_id)).to eq(ret_val)
      expect(client).to have_received(:http_get).with(path: path_string)
    end
  end

  describe "#delete" do
    let(:file_id) { SecureRandom.hex(4) }
    let(:path_string) { "/v1/files/#{file_id}" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:http_delete).with(path: path_string).and_return(ret_val)
      expect(files.delete(file_id: file_id)).to eq(ret_val)
      expect(client).to have_received(:http_delete).with(path: path_string)
    end
  end
end
