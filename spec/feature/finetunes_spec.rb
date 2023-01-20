require_relative "../spec_helper"

RSpec.describe "Finetunes API", type: :feature do
  context "when running a set of file actions", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { Utils.fixture_filename(filename: filename) }
    let(:cassette) { "successful fine tune model creation" }
    let(:model) { "ada" }
    let(:client) { Asimov::Client.new }

    it "successfully uploads files, creates a corresponding fine-tuned model, and lists " \
       "the results." do
      VCR.use_cassette(cassette) do
        # Upload a training file
        r = client.files.upload(parameters: { file: file, purpose: "fine-tune" })
        file_id = r["id"]

        # Create a fine tuned model
        r = client.finetunes.create(
          parameters: {
            training_file: file_id,
            model: model
          }
        )
        expect(r["object"]).to eq("fine-tune")
        fine_tune_id = r["id"]

        # List the fine tuning jobs
        r = client.finetunes.list
        job_list = r["data"]
        expect(job_list.size).to be > 0
        expect(job_list[0]["object"]).to eq("fine-tune")

        # List the fine tuning events
        r = client.finetunes.list_events(fine_tune_id: fine_tune_id)
        job_list = r["data"]
        expect(job_list.size).to be > 0
        expect(job_list[0]["object"]).to eq("fine-tune-event")

        # Retrieve the fine tune job that was created
        r = client.finetunes.retrieve(fine_tune_id: fine_tune_id)
        expect(r["object"]).to eq("fine-tune")
        expect(r["id"]).to eq(fine_tune_id)
        model_id = r["fine_tuned_model"]

        # Delete the model if one is created
        if model_id
          # Give the model time to complete if running against the real API
          sleep 2 if ENV["RUN_LIVE"]

          client.models.delete(id: model_id)
        else
          client.finetunes.cancel(fine_tune_id: fine_tune_id)
        end

        # Give the file time to process if running against the real API
        sleep 20 if ENV["RUN_LIVE"]

        # Delete the uploaded file
        client.files.delete(file_id: file_id)
      end
    end
  end

  describe "retrieving a fine-tune job that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("fine tune job retrieve with non-existent id") do
        expect do
          client.finetunes.retrieve(fine_tune_id: "nosuchfinetune")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end

  describe "cancelling a fine-tune job that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("fine tune job cancel with non-existent id") do
        expect do
          client.finetunes.cancel(fine_tune_id: "nosuchfinetune")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end

  describe "listing events for a fine-tune job that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("fine tune job list events with non-existent id") do
        expect do
          client.finetunes.list_events(fine_tune_id: "nosuchfinetune")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end
end
