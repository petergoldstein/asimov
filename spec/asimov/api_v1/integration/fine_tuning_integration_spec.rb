require_relative "../../../spec_helper"

RSpec.describe Asimov::ApiV1::FineTuning, type: :integration do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:fine_tuning) { client.fine_tuning }
  let(:base_url) { "https://api.openai.com/v1/fine_tuning/jobs" }

  describe "#create" do
    it "returns parsed response on success" do
      body = { "id" => "ftjob-abc123", "object" => "fine_tuning.job", "status" => "queued" }
      stub_request(:post, base_url).to_return(status: 200, body: body.to_json,
                                              headers: { "Content-Type" => "application/json" })

      result = fine_tuning.create(model: "gpt-4o-mini-2024-07-18", training_file: "file-abc123")
      expect(result["id"]).to eq("ftjob-abc123")
      expect(result["status"]).to eq("queued")
    end
  end

  describe "#retrieve" do
    it "returns parsed response on success" do
      body = { "id" => "ftjob-abc123", "object" => "fine_tuning.job" }
      stub_request(:get, "#{base_url}/ftjob-abc123")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = fine_tuning.retrieve(fine_tuning_job_id: "ftjob-abc123")
      expect(result["id"]).to eq("ftjob-abc123")
    end

    it "raises NotFoundError on 404" do
      error_body = { "error" => { "message" => "No fine-tuning job found" } }
      stub_request(:get, "#{base_url}/ftjob-nonexistent")
        .to_return(status: 404, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        fine_tuning.retrieve(fine_tuning_job_id: "ftjob-nonexistent")
      end.to raise_error(Asimov::NotFoundError)
    end
  end

  describe "#list" do
    it "returns list of fine-tuning jobs" do
      body = { "object" => "list", "data" => [{ "id" => "ftjob-1" }, { "id" => "ftjob-2" }] }
      stub_request(:get, base_url)
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = fine_tuning.list
      expect(result["data"].length).to eq(2)
    end
  end

  describe "#list_events" do
    it "returns events for a fine-tuning job" do
      body = { "object" => "list", "data" => [{ "object" => "fine_tuning.job.event" }] }
      stub_request(:get, "#{base_url}/ftjob-abc123/events")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = fine_tuning.list_events(fine_tuning_job_id: "ftjob-abc123")
      expect(result["data"].first["object"]).to eq("fine_tuning.job.event")
    end
  end

  describe "#cancel" do
    it "returns parsed response on success" do
      body = { "id" => "ftjob-abc123", "status" => "cancelled" }
      stub_request(:post, "#{base_url}/ftjob-abc123/cancel")
        .to_return(status: 200, body: body.to_json,
                   headers: { "Content-Type" => "application/json" })

      result = fine_tuning.cancel(fine_tuning_job_id: "ftjob-abc123")
      expect(result["status"]).to eq("cancelled")
    end

    it "raises RateLimitError on 429" do
      error_body = { "error" => { "message" => "Rate limit reached" } }
      stub_request(:post, "#{base_url}/ftjob-abc123/cancel")
        .to_return(status: 429, body: error_body.to_json,
                   headers: { "Content-Type" => "application/json" })

      expect do
        fine_tuning.cancel(fine_tuning_job_id: "ftjob-abc123")
      end.to raise_error(Asimov::RateLimitError)
    end
  end
end
