require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Evals do
  subject(:evals) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "evals" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    it "calls rest_create_w_json_params with the expected arguments" do
      allow(evals).to receive(:rest_create_w_json_params)
        .with(resource: resource, parameters: parameters)
        .and_return(ret_val)
      expect(evals.create(parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(evals).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(evals.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "eval_abc123", limit: 20 }
      allow(evals).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(evals.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.retrieve(eval_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(evals).to receive(:rest_get)
        .with(resource: resource, id: eval_id)
        .and_return(ret_val)
      expect(evals.retrieve(eval_id: eval_id)).to eq(ret_val)
    end
  end

  describe "#update" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.update(eval_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(evals).to receive(:rest_create_w_json_params)
        .with(resource: [resource, eval_id], parameters: parameters)
        .and_return(ret_val)
      expect(evals.update(eval_id: eval_id, parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.delete(eval_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(evals).to receive(:rest_delete)
        .with(resource: resource, id: eval_id)
        .and_return(ret_val)
      expect(evals.delete(eval_id: eval_id)).to eq(ret_val)
    end
  end

  describe "#create_run" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.create_run(eval_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(evals).to receive(:rest_create_w_json_params)
        .with(resource: [resource, eval_id, "runs"], parameters: parameters)
        .and_return(ret_val)
      expect(evals.create_run(eval_id: eval_id, parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#list_runs" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.list_runs(eval_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(evals).to receive(:rest_index)
        .with(resource: [resource, eval_id, "runs"], parameters: {})
        .and_return(ret_val)
      expect(evals.list_runs(eval_id: eval_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "run_abc123", limit: 10 }
      allow(evals).to receive(:rest_index)
        .with(resource: [resource, eval_id, "runs"], parameters: pagination)
        .and_return(ret_val)
      expect(evals.list_runs(eval_id: eval_id, parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve_run" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }
    let(:run_id) { "run_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.retrieve_run(eval_id: nil, run_id: run_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when run_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.retrieve_run(eval_id: eval_id, run_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(evals).to receive(:rest_get)
        .with(resource: "#{resource}/#{eval_id}/runs", id: run_id)
        .and_return(ret_val)
      expect(evals.retrieve_run(eval_id: eval_id, run_id: run_id)).to eq(ret_val)
    end
  end

  describe "#cancel_run" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }
    let(:run_id) { "run_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.cancel_run(eval_id: nil, run_id: run_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when run_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.cancel_run(eval_id: eval_id, run_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(evals).to receive(:rest_create_w_json_params)
        .with(resource: [resource, eval_id, "runs", run_id, "cancel"], parameters: nil)
        .and_return(ret_val)
      expect(evals.cancel_run(eval_id: eval_id, run_id: run_id)).to eq(ret_val)
    end
  end

  describe "#delete_run" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }
    let(:run_id) { "run_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.delete_run(eval_id: nil, run_id: run_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when run_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.delete_run(eval_id: eval_id, run_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(evals).to receive(:rest_delete)
        .with(resource: "#{resource}/#{eval_id}/runs", id: run_id)
        .and_return(ret_val)
      expect(evals.delete_run(eval_id: eval_id, run_id: run_id)).to eq(ret_val)
    end
  end

  describe "#list_output_items" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }
    let(:run_id) { "run_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.list_output_items(eval_id: nil, run_id: run_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when run_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.list_output_items(eval_id: eval_id, run_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(evals).to receive(:rest_index)
        .with(resource: [resource, eval_id, "runs", run_id, "output_items"], parameters: {})
        .and_return(ret_val)
      expect(evals.list_output_items(eval_id: eval_id, run_id: run_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "outputitem_abc123", limit: 10 }
      allow(evals).to receive(:rest_index)
        .with(resource: [resource, eval_id, "runs", run_id, "output_items"],
              parameters: pagination)
        .and_return(ret_val)
      expect(evals.list_output_items(eval_id: eval_id, run_id: run_id,
                                     parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve_output_item" do
    let(:eval_id) { "eval_#{SecureRandom.hex(4)}" }
    let(:run_id) { "run_#{SecureRandom.hex(4)}" }
    let(:output_item_id) { "outputitem_#{SecureRandom.hex(4)}" }

    context "when eval_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.retrieve_output_item(eval_id: nil, run_id: run_id, output_item_id: output_item_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when run_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.retrieve_output_item(eval_id: eval_id, run_id: nil, output_item_id: output_item_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when output_item_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          evals.retrieve_output_item(eval_id: eval_id, run_id: run_id, output_item_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(evals).to receive(:rest_get)
        .with(resource: "#{resource}/#{eval_id}/runs/#{run_id}/output_items", id: output_item_id)
        .and_return(ret_val)
      expect(evals.retrieve_output_item(eval_id: eval_id, run_id: run_id,
                                        output_item_id: output_item_id)).to eq(ret_val)
    end
  end
end
