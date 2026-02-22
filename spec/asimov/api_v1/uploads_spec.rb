require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Uploads do
  subject(:uploads) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "uploads" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:filename) { "training_data.jsonl" }
    let(:purpose) { "fine-tune" }
    let(:bytes) { 2_147_483_648 }
    let(:mime_type) { "application/jsonl" }

    context "when required parameters are present" do
      let(:merged_params) do
        parameters.merge(filename: filename, purpose: purpose,
                         bytes: bytes, mime_type: mime_type)
      end

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(uploads).to receive(:rest_create_w_json_params)
          .with(resource: resource, parameters: merged_params)
          .and_return(ret_val)
        expect(uploads.create(filename: filename, purpose: purpose,
                              bytes: bytes, mime_type: mime_type,
                              parameters: parameters)).to eq(ret_val)
      end
    end

    context "when filename is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.create(filename: nil, purpose: "fine-tune", bytes: 100, mime_type: "text/plain")
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when purpose is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.create(filename: "f.jsonl", purpose: nil, bytes: 100, mime_type: "text/plain")
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when bytes is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.create(filename: "f.jsonl", purpose: "fine-tune", bytes: nil,
                         mime_type: "text/plain")
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when mime_type is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.create(filename: "f.jsonl", purpose: "fine-tune", bytes: 100, mime_type: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#add_part" do
    let(:upload_id) { "upload_#{SecureRandom.hex(4)}" }
    let(:data) { instance_double(File) }

    context "when upload_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.add_part(upload_id: nil, data: data)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when data is present" do
      it "calls rest_create_w_multipart_params with the expected arguments" do
        allow(uploads).to receive(:rest_create_w_multipart_params)
          .with(resource: [resource, upload_id, "parts"], parameters: { data: data })
          .and_return(ret_val)
        expect(uploads.add_part(upload_id: upload_id, data: data)).to eq(ret_val)
      end
    end

    context "when data is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.add_part(upload_id: upload_id, data: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#complete" do
    let(:upload_id) { "upload_#{SecureRandom.hex(4)}" }
    let(:part_ids) { ["part_#{SecureRandom.hex(4)}", "part_#{SecureRandom.hex(4)}"] }

    context "when upload_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.complete(upload_id: nil, part_ids: part_ids)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when part_ids is present" do
      let(:merged_params) { parameters.merge(part_ids: part_ids) }

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(uploads).to receive(:rest_create_w_json_params)
          .with(resource: [resource, upload_id, "complete"], parameters: merged_params)
          .and_return(ret_val)
        expect(uploads.complete(upload_id: upload_id, part_ids: part_ids,
                                parameters: parameters)).to eq(ret_val)
      end
    end

    context "when part_ids is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.complete(upload_id: upload_id, part_ids: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#cancel" do
    let(:upload_id) { "upload_#{SecureRandom.hex(4)}" }

    context "when upload_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          uploads.cancel(upload_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(uploads).to receive(:rest_create_w_json_params)
        .with(resource: [resource, upload_id, "cancel"], parameters: nil)
        .and_return(ret_val)
      expect(uploads.cancel(upload_id: upload_id)).to eq(ret_val)
    end
  end
end
