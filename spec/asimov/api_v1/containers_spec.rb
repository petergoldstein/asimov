require_relative "../../spec_helper"
require "tempfile"

RSpec.describe Asimov::ApiV1::Containers do
  subject(:containers) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "containers" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:name) { "my-container" }

    context "when name is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(name: name)
        allow(containers).to receive(:rest_create_w_json_params)
          .with(resource: resource, parameters: merged)
          .and_return(ret_val)
        expect(containers.create(name: name, parameters: parameters)).to eq(ret_val)
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.create(name: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(containers).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(containers.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "ctr_abc123", limit: 20 }
      allow(containers).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(containers.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.retrieve(container_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(containers).to receive(:rest_get)
        .with(resource: resource, id: container_id)
        .and_return(ret_val)
      expect(containers.retrieve(container_id: container_id)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.delete(container_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(containers).to receive(:rest_delete)
        .with(resource: resource, id: container_id)
        .and_return(ret_val)
      expect(containers.delete(container_id: container_id)).to eq(ret_val)
    end
  end

  describe "#create_file" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }
    let(:filename) { SecureRandom.hex(4) }
    let(:file_instance) { instance_double(File) }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.create_file(container_id: nil, file: filename)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file is present and can be opened" do
      let(:merged_parameters) { parameters.merge(file: file_instance) }

      before do
        allow(File).to receive(:open).with(filename).and_return(file_instance)
        allow(containers).to receive(:rest_create_w_multipart_params)
          .with(resource: [resource, container_id, "files"],
                parameters: merged_parameters)
          .and_return(ret_val)
      end

      it "calls rest_create_w_multipart_params with the expected arguments" do
        expect(containers.create_file(container_id: container_id, file: filename,
                                      parameters: parameters)).to eq(ret_val)
      end
    end

    context "when file is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.create_file(container_id: container_id, file: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when the file cannot be opened" do
      before do
        allow(File).to receive(:open).with(filename).and_raise(Errno::ENOENT)
      end

      it "raises a FileCannotBeOpenedError" do
        expect do
          containers.create_file(container_id: container_id, file: filename)
        end.to raise_error(Asimov::FileCannotBeOpenedError)
      end
    end
  end

  describe "#list_files" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.list_files(container_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(containers).to receive(:rest_index)
        .with(resource: [resource, container_id, "files"], parameters: {})
        .and_return(ret_val)
      expect(containers.list_files(container_id: container_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "file_abc123", limit: 10 }
      allow(containers).to receive(:rest_index)
        .with(resource: [resource, container_id, "files"], parameters: pagination)
        .and_return(ret_val)
      expect(containers.list_files(container_id: container_id,
                                   parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve_file" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }
    let(:file_id) { "file-#{SecureRandom.hex(4)}" }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.retrieve_file(container_id: nil, file_id: file_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.retrieve_file(container_id: container_id, file_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(containers).to receive(:rest_get)
        .with(resource: "#{resource}/#{container_id}/files", id: file_id)
        .and_return(ret_val)
      expect(containers.retrieve_file(container_id: container_id,
                                      file_id: file_id)).to eq(ret_val)
    end
  end

  describe "#delete_file" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }
    let(:file_id) { "file-#{SecureRandom.hex(4)}" }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.delete_file(container_id: nil, file_id: file_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.delete_file(container_id: container_id, file_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(containers).to receive(:rest_delete)
        .with(resource: "#{resource}/#{container_id}/files", id: file_id)
        .and_return(ret_val)
      expect(containers.delete_file(container_id: container_id,
                                    file_id: file_id)).to eq(ret_val)
    end
  end

  describe "#file_content" do
    let(:container_id) { "ctr_#{SecureRandom.hex(4)}" }
    let(:file_id) { "file-#{SecureRandom.hex(4)}" }
    let(:writer) { instance_double(Tempfile) }

    context "when container_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.file_content(container_id: nil, file_id: file_id, writer: writer)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          containers.file_content(container_id: container_id, file_id: nil, writer: writer)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get_streamed_download with the expected arguments" do
      allow(containers).to receive(:rest_get_streamed_download)
        .with(resource: [resource, container_id, "files", file_id, "content"],
              writer: writer)
        .and_return(ret_val)
      expect(containers.file_content(container_id: container_id, file_id: file_id,
                                     writer: writer)).to eq(ret_val)
    end
  end
end
