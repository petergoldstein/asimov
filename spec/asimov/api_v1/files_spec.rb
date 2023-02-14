require_relative "../../spec_helper"
require "tempfile"

RSpec.describe Asimov::ApiV1::Files do
  subject(:files) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "files" }

  it_behaves_like "sends requests to the v1 API"

  describe "#list" do
    it "calls get on the client with the expected arguments" do
      allow(files).to receive(:rest_index).with(resource: resource).and_return(ret_val)
      expect(files.list).to eq(ret_val)
      expect(files).to have_received(:rest_index).with(resource: resource)
    end
  end

  describe "#upload" do
    {
      "fine-tune" => Asimov::Utils::TrainingFileValidator,
      "classifications" => Asimov::Utils::ClassificationsFileValidator,
      "answers" => Asimov::Utils::TextEntryFileValidator,
      "search" => Asimov::Utils::TextEntryFileValidator
    }.each do |type, validator|
      context "when the parameters include a :purpose value of #{type}" do
        let(:purpose) { type }
        let(:validator_class) { validator }
        let(:validator_instance) { instance_double(validator_class) }

        context "when the parameters include a :file value" do
          let(:filename) { SecureRandom.hex(4) }
          let(:file_instance1) { instance_double(File) }
          let(:file_instance2) { instance_double(File) }

          context "when the file can be loaded" do
            let(:merged_parameters) { parameters.merge({ file: file_instance2, purpose: purpose }) }

            before do
              allow(File).to receive(:open).with(filename).and_return(file_instance1,
                                                                      file_instance2)
              allow(files).to receive(:multipart_post)
                .with(path: "/files",
                      parameters: merged_parameters)
                .and_return(ret_val)
              allow(validator_class).to receive(:new).and_return(validator_instance)
            end

            context "when the file passes JSONL validation" do
              before do
                allow(validator_instance).to receive(:validate)
                  .with(file_instance1)
                  .and_return(true)
              end

              it "runs JSONL validation and passes to the client" do
                val = files.upload(file: filename, purpose: purpose, parameters: parameters)
                expect(val).to eq(ret_val)
                expect(validator_instance).to have_received(:validate)
                  .with(file_instance1)
                expect(files).to have_received(:multipart_post).with(path: "/files",
                                                                     parameters: merged_parameters)
              end
            end

            context "when the file does not pass JSONL validation" do
              before do
                allow(validator_instance).to receive(:validate)
                  .with(file_instance1)
                  .and_raise(Asimov::JsonlFileCannotBeParsedError)
              end

              it "runs JSONL validation and does not pass to the client" do
                expect do
                  files.upload(file: filename, purpose: purpose, parameters: parameters)
                end.to raise_error(Asimov::JsonlFileCannotBeParsedError)
                expect(validator_instance).to have_received(:validate)
                  .with(file_instance1)
                expect(files).not_to have_received(:multipart_post).with(anything)
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
                files.upload(file: filename, purpose: purpose, parameters: parameters)
              end.to raise_error(Asimov::FileCannotBeOpenedError)
            end
          end
        end

        context "when the parameters do not include a :file value" do
          it "raises a MissingRequiredParameterError" do
            expect do
              files.upload(file: nil, purpose: purpose)
            end.to raise_error(Asimov::MissingRequiredParameterError)

            expect do
              files.upload(file: nil, purpose: purpose, parameters: parameters)
            end.to raise_error(Asimov::MissingRequiredParameterError)
          end
        end
      end
    end

    context "when the parameters do not include a :purpose value" do
      let(:filename) { SecureRandom.hex(4) }

      it "raises an error before calling anything" do
        expect do
          files.upload(file: filename, purpose: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)

        expect do
          files.upload(file: filename, purpose: nil, parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when the parameters do not include either the :file or :purpose values" do
      it "raises an error before calling anything" do
        expect do
          files.upload(file: nil, purpose: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)

        expect do
          files.upload(file: nil, purpose: nil, parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve" do
    let(:file_id) { SecureRandom.hex(4) }

    it "calls get on the client with the expected arguments" do
      allow(files).to receive(:rest_get).with(resource: resource, id: file_id).and_return(ret_val)
      expect(files.retrieve(file_id: file_id)).to eq(ret_val)
      expect(files).to have_received(:rest_get).with(resource: resource, id: file_id)
    end
  end

  describe "#content" do
    let(:file_id) { SecureRandom.hex(4) }
    let(:writer) { instance_double(Tempfile) }

    it "calls get on the client with the expected arguments" do
      allow(files).to receive(:rest_get_streamed_download)
        .with(resource: [resource, file_id, "content"],
              writer: writer).and_return(ret_val)
      expect(files.content(file_id: file_id, writer: writer)).to eq(ret_val)
      expect(files).to have_received(:rest_get_streamed_download)
        .with(resource: [resource, file_id, "content"],
              writer: writer)
    end
  end

  describe "#delete" do
    let(:file_id) { SecureRandom.hex(4) }

    it "calls get on the client with the expected arguments" do
      allow(files).to receive(:rest_delete).with(resource: resource,
                                                 id: file_id).and_return(ret_val)
      expect(files.delete(file_id: file_id)).to eq(ret_val)
      expect(files).to have_received(:rest_delete).with(resource: resource, id: file_id)
    end
  end
end
