require_relative "../../spec_helper"
require "tempfile"

RSpec.describe Asimov::ApiV1::Skills do
  subject(:skills) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "skills" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:filename) { SecureRandom.hex(4) }
    let(:file_instance) { instance_double(File) }

    context "when file is present and can be opened" do
      let(:merged_parameters) { parameters.merge(files: file_instance) }

      before do
        allow(File).to receive(:open).with(filename).and_return(file_instance)
        allow(skills).to receive(:rest_create_w_multipart_params)
          .with(resource: resource, parameters: merged_parameters)
          .and_return(ret_val)
      end

      it "calls rest_create_w_multipart_params with the expected arguments" do
        expect(skills.create(file: filename, parameters: parameters)).to eq(ret_val)
      end
    end

    context "when file is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.create(file: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when the file cannot be opened" do
      before do
        allow(File).to receive(:open).with(filename).and_raise(Errno::ENOENT)
      end

      it "raises a FileCannotBeOpenedError" do
        expect do
          skills.create(file: filename)
        end.to raise_error(Asimov::FileCannotBeOpenedError)
      end
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(skills).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(skills.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "skill_abc123", limit: 20 }
      allow(skills).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(skills.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.retrieve(skill_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(skills).to receive(:rest_get)
        .with(resource: resource, id: skill_id)
        .and_return(ret_val)
      expect(skills.retrieve(skill_id: skill_id)).to eq(ret_val)
    end
  end

  describe "#update" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.update(skill_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(skills).to receive(:rest_create_w_json_params)
        .with(resource: [resource, skill_id], parameters: parameters)
        .and_return(ret_val)
      expect(skills.update(skill_id: skill_id, parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.delete(skill_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(skills).to receive(:rest_delete)
        .with(resource: resource, id: skill_id)
        .and_return(ret_val)
      expect(skills.delete(skill_id: skill_id)).to eq(ret_val)
    end
  end

  describe "#content" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }
    let(:writer) { instance_double(Tempfile) }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.content(skill_id: nil, writer: writer)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get_streamed_download with the expected arguments" do
      allow(skills).to receive(:rest_get_streamed_download)
        .with(resource: [resource, skill_id, "content"], writer: writer)
        .and_return(ret_val)
      expect(skills.content(skill_id: skill_id, writer: writer)).to eq(ret_val)
    end
  end

  describe "#create_version" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }
    let(:filename) { SecureRandom.hex(4) }
    let(:file_instance) { instance_double(File) }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.create_version(skill_id: nil, file: filename)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file is present and can be opened" do
      let(:merged_parameters) { parameters.merge(files: file_instance) }

      before do
        allow(File).to receive(:open).with(filename).and_return(file_instance)
        allow(skills).to receive(:rest_create_w_multipart_params)
          .with(resource: [resource, skill_id, "versions"],
                parameters: merged_parameters)
          .and_return(ret_val)
      end

      it "calls rest_create_w_multipart_params with the expected arguments" do
        expect(skills.create_version(skill_id: skill_id, file: filename,
                                     parameters: parameters)).to eq(ret_val)
      end
    end

    context "when file is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.create_version(skill_id: skill_id, file: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when the file cannot be opened" do
      before do
        allow(File).to receive(:open).with(filename).and_raise(Errno::ENOENT)
      end

      it "raises a FileCannotBeOpenedError" do
        expect do
          skills.create_version(skill_id: skill_id, file: filename)
        end.to raise_error(Asimov::FileCannotBeOpenedError)
      end
    end
  end

  describe "#list_versions" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.list_versions(skill_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(skills).to receive(:rest_index)
        .with(resource: [resource, skill_id, "versions"], parameters: {})
        .and_return(ret_val)
      expect(skills.list_versions(skill_id: skill_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "ver_abc123", limit: 10 }
      allow(skills).to receive(:rest_index)
        .with(resource: [resource, skill_id, "versions"], parameters: pagination)
        .and_return(ret_val)
      expect(skills.list_versions(skill_id: skill_id,
                                  parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve_version" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.retrieve_version(skill_id: nil, version: "latest")
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when version is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.retrieve_version(skill_id: skill_id, version: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "with an integer version" do
      let(:version) { rand(1..10) }

      it "calls rest_get with the version converted to a string" do
        allow(skills).to receive(:rest_get)
          .with(resource: "#{resource}/#{skill_id}/versions", id: version.to_s)
          .and_return(ret_val)
        expect(skills.retrieve_version(skill_id: skill_id, version: version)).to eq(ret_val)
      end
    end

    context "with 'latest' as the version" do
      it "calls rest_get with the expected arguments" do
        allow(skills).to receive(:rest_get)
          .with(resource: "#{resource}/#{skill_id}/versions", id: "latest")
          .and_return(ret_val)
        expect(skills.retrieve_version(skill_id: skill_id, version: "latest")).to eq(ret_val)
      end
    end
  end

  describe "#delete_version" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.delete_version(skill_id: nil, version: "latest")
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when version is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.delete_version(skill_id: skill_id, version: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "with an integer version" do
      let(:version) { rand(1..10) }

      it "calls rest_delete with the version converted to a string" do
        allow(skills).to receive(:rest_delete)
          .with(resource: "#{resource}/#{skill_id}/versions", id: version.to_s)
          .and_return(ret_val)
        expect(skills.delete_version(skill_id: skill_id, version: version)).to eq(ret_val)
      end
    end

    context "with 'latest' as the version" do
      it "calls rest_delete with the expected arguments" do
        allow(skills).to receive(:rest_delete)
          .with(resource: "#{resource}/#{skill_id}/versions", id: "latest")
          .and_return(ret_val)
        expect(skills.delete_version(skill_id: skill_id, version: "latest")).to eq(ret_val)
      end
    end
  end

  describe "#version_content" do
    let(:skill_id) { "skill_#{SecureRandom.hex(4)}" }
    let(:version) { rand(1..10) }
    let(:writer) { instance_double(Tempfile) }

    context "when skill_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.version_content(skill_id: nil, version: version, writer: writer)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when version is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          skills.version_content(skill_id: skill_id, version: nil, writer: writer)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get_streamed_download with the expected arguments" do
      allow(skills).to receive(:rest_get_streamed_download)
        .with(resource: [resource, skill_id, "versions", version, "content"],
              writer: writer)
        .and_return(ret_val)
      expect(skills.version_content(skill_id: skill_id, version: version,
                                    writer: writer)).to eq(ret_val)
    end
  end
end
