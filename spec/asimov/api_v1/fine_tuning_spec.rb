require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::FineTuning do
  subject(:fine_tuning) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "fine_tuning" }
  let(:jobs_resource) { %w[fine_tuning jobs] }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:model) { SecureRandom.hex(4) }
    let(:training_file) { "file-#{SecureRandom.hex(4)}" }

    context "when required parameters are present" do
      let(:merged_params) { parameters.merge(model: model, training_file: training_file) }

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(fine_tuning).to receive(:rest_create_w_json_params)
          .with(resource: jobs_resource, parameters: merged_params)
          .and_return(ret_val)
        expect(fine_tuning.create(model: model, training_file: training_file,
                                  parameters: parameters)).to eq(ret_val)
      end
    end

    context "when model is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.create(model: nil, training_file: "file-123")
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when training_file is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.create(model: "gpt-4o-mini-2024-07-18", training_file: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(fine_tuning).to receive(:rest_index)
        .with(resource: jobs_resource, parameters: {})
        .and_return(ret_val)
      expect(fine_tuning.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "ftjob-abc123", limit: 10 }
      allow(fine_tuning).to receive(:rest_index)
        .with(resource: jobs_resource, parameters: pagination)
        .and_return(ret_val)
      expect(fine_tuning.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:job_id) { "ftjob-#{SecureRandom.hex(4)}" }

    context "when fine_tuning_job_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.retrieve(fine_tuning_job_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(fine_tuning).to receive(:rest_get)
        .with(resource: "fine_tuning/jobs", id: job_id)
        .and_return(ret_val)
      expect(fine_tuning.retrieve(fine_tuning_job_id: job_id)).to eq(ret_val)
    end
  end

  describe "#cancel" do
    let(:job_id) { "ftjob-#{SecureRandom.hex(4)}" }

    context "when fine_tuning_job_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.cancel(fine_tuning_job_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(fine_tuning).to receive(:rest_create_w_json_params)
        .with(resource: %w[fine_tuning jobs] + [job_id, "cancel"], parameters: nil)
        .and_return(ret_val)
      expect(fine_tuning.cancel(fine_tuning_job_id: job_id)).to eq(ret_val)
    end
  end

  describe "#pause" do
    let(:job_id) { "ftjob-#{SecureRandom.hex(4)}" }

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(fine_tuning).to receive(:rest_create_w_json_params)
        .with(resource: %w[fine_tuning jobs] + [job_id, "pause"], parameters: nil)
        .and_return(ret_val)
      expect(fine_tuning.pause(fine_tuning_job_id: job_id)).to eq(ret_val)
    end

    context "when fine_tuning_job_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.pause(fine_tuning_job_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#resume" do
    let(:job_id) { "ftjob-#{SecureRandom.hex(4)}" }

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(fine_tuning).to receive(:rest_create_w_json_params)
        .with(resource: %w[fine_tuning jobs] + [job_id, "resume"], parameters: nil)
        .and_return(ret_val)
      expect(fine_tuning.resume(fine_tuning_job_id: job_id)).to eq(ret_val)
    end

    context "when fine_tuning_job_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.resume(fine_tuning_job_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_events" do
    let(:job_id) { "ftjob-#{SecureRandom.hex(4)}" }

    context "when fine_tuning_job_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.list_events(fine_tuning_job_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(fine_tuning).to receive(:rest_index)
        .with(resource: %w[fine_tuning jobs] + [job_id, "events"], parameters: {})
        .and_return(ret_val)
      expect(fine_tuning.list_events(fine_tuning_job_id: job_id)).to eq(ret_val)
    end
  end

  describe "#list_checkpoints" do
    let(:job_id) { "ftjob-#{SecureRandom.hex(4)}" }

    context "when fine_tuning_job_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          fine_tuning.list_checkpoints(fine_tuning_job_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(fine_tuning).to receive(:rest_index)
        .with(resource: %w[fine_tuning jobs] + [job_id, "checkpoints"], parameters: {})
        .and_return(ret_val)
      expect(fine_tuning.list_checkpoints(fine_tuning_job_id: job_id)).to eq(ret_val)
    end
  end
end
