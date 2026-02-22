require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::VectorStores do
  subject(:vector_stores) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "vector_stores" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    it "calls rest_create_w_json_params with the expected arguments" do
      allow(vector_stores).to receive(:rest_create_w_json_params)
        .with(resource: resource, parameters: parameters)
        .and_return(ret_val)
      expect(vector_stores.create(parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(vector_stores).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(vector_stores.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "vs_abc123", limit: 20 }
      allow(vector_stores).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(vector_stores.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.retrieve(vector_store_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(vector_stores).to receive(:rest_get)
        .with(resource: resource, id: vector_store_id)
        .and_return(ret_val)
      expect(vector_stores.retrieve(vector_store_id: vector_store_id)).to eq(ret_val)
    end
  end

  describe "#update" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.update(vector_store_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(vector_stores).to receive(:rest_create_w_json_params)
        .with(resource: [resource, vector_store_id], parameters: parameters)
        .and_return(ret_val)
      expect(vector_stores.update(vector_store_id: vector_store_id,
                                  parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.delete(vector_store_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(vector_stores).to receive(:rest_delete)
        .with(resource: resource, id: vector_store_id)
        .and_return(ret_val)
      expect(vector_stores.delete(vector_store_id: vector_store_id)).to eq(ret_val)
    end
  end

  describe "#search" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:query) { "search query" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.search(vector_store_id: nil, query: query)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when query is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(query: query)
        allow(vector_stores).to receive(:rest_create_w_json_params)
          .with(resource: [resource, vector_store_id, "search"], parameters: merged)
          .and_return(ret_val)
        expect(vector_stores.search(vector_store_id: vector_store_id, query: query,
                                    parameters: parameters)).to eq(ret_val)
      end
    end

    context "when query is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.search(vector_store_id: vector_store_id, query: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#create_file" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_id) { "file-#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.create_file(vector_store_id: nil, file_id: file_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_id is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(file_id: file_id)
        allow(vector_stores).to receive(:rest_create_w_json_params)
          .with(resource: [resource, vector_store_id, "files"], parameters: merged)
          .and_return(ret_val)
        expect(vector_stores.create_file(vector_store_id: vector_store_id, file_id: file_id,
                                         parameters: parameters)).to eq(ret_val)
      end
    end

    context "when file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.create_file(vector_store_id: vector_store_id, file_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_files" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.list_files(vector_store_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(vector_stores).to receive(:rest_index)
        .with(resource: [resource, vector_store_id, "files"], parameters: {})
        .and_return(ret_val)
      expect(vector_stores.list_files(vector_store_id: vector_store_id)).to eq(ret_val)
    end
  end

  describe "#retrieve_file" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_id) { "file-#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.retrieve_file(vector_store_id: nil, file_id: file_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.retrieve_file(vector_store_id: vector_store_id, file_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(vector_stores).to receive(:rest_get)
        .with(resource: "#{resource}/#{vector_store_id}/files", id: file_id)
        .and_return(ret_val)
      expect(vector_stores.retrieve_file(vector_store_id: vector_store_id,
                                         file_id: file_id)).to eq(ret_val)
    end
  end

  describe "#delete_file" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_id) { "file-#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.delete_file(vector_store_id: nil, file_id: file_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.delete_file(vector_store_id: vector_store_id, file_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(vector_stores).to receive(:rest_delete)
        .with(resource: "#{resource}/#{vector_store_id}/files", id: file_id)
        .and_return(ret_val)
      expect(vector_stores.delete_file(vector_store_id: vector_store_id,
                                       file_id: file_id)).to eq(ret_val)
    end
  end

  describe "#create_file_batch" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_ids) { ["file-#{SecureRandom.hex(4)}", "file-#{SecureRandom.hex(4)}"] }

    context "when required parameters are present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(file_ids: file_ids)
        allow(vector_stores).to receive(:rest_create_w_json_params)
          .with(resource: [resource, vector_store_id, "file_batches"], parameters: merged)
          .and_return(ret_val)
        expect(vector_stores.create_file_batch(vector_store_id: vector_store_id,
                                               file_ids: file_ids,
                                               parameters: parameters)).to eq(ret_val)
      end
    end

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.create_file_batch(vector_store_id: nil, file_ids: file_ids)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_ids is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.create_file_batch(vector_store_id: vector_store_id, file_ids: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve_file_batch" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_batch_id) { "vsfb_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.retrieve_file_batch(vector_store_id: nil, file_batch_id: file_batch_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_batch_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.retrieve_file_batch(vector_store_id: vector_store_id, file_batch_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(vector_stores).to receive(:rest_get)
        .with(resource: "#{resource}/#{vector_store_id}/file_batches", id: file_batch_id)
        .and_return(ret_val)
      expect(vector_stores.retrieve_file_batch(vector_store_id: vector_store_id,
                                               file_batch_id: file_batch_id)).to eq(ret_val)
    end
  end

  describe "#cancel_file_batch" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_batch_id) { "vsfb_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.cancel_file_batch(vector_store_id: nil, file_batch_id: file_batch_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_batch_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.cancel_file_batch(vector_store_id: vector_store_id, file_batch_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(vector_stores).to receive(:rest_create_w_json_params)
        .with(
          resource: [resource, vector_store_id, "file_batches", file_batch_id, "cancel"],
          parameters: nil
        )
        .and_return(ret_val)
      expect(vector_stores.cancel_file_batch(vector_store_id: vector_store_id,
                                             file_batch_id: file_batch_id)).to eq(ret_val)
    end
  end

  describe "#list_file_batch_files" do
    let(:vector_store_id) { "vs_#{SecureRandom.hex(4)}" }
    let(:file_batch_id) { "vsfb_#{SecureRandom.hex(4)}" }

    context "when vector_store_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.list_file_batch_files(vector_store_id: nil, file_batch_id: file_batch_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when file_batch_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          vector_stores.list_file_batch_files(vector_store_id: vector_store_id,
                                              file_batch_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(vector_stores).to receive(:rest_index)
        .with(
          resource: [resource, vector_store_id, "file_batches", file_batch_id, "files"],
          parameters: {}
        )
        .and_return(ret_val)
      expect(vector_stores.list_file_batch_files(vector_store_id: vector_store_id,
                                                 file_batch_id: file_batch_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "file_abc123", limit: 10 }
      allow(vector_stores).to receive(:rest_index)
        .with(
          resource: [resource, vector_store_id, "file_batches", file_batch_id, "files"],
          parameters: pagination
        )
        .and_return(ret_val)
      expect(vector_stores.list_file_batch_files(
               vector_store_id: vector_store_id,
               file_batch_id: file_batch_id,
               parameters: pagination
             )).to eq(ret_val)
    end
  end
end
