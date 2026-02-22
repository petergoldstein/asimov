require_relative "../../spec_helper"
require "tempfile"

RSpec.describe Asimov::ApiV1::Videos do
  subject(:videos) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "videos" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:model) { "sora" }
    let(:prompt) { SecureRandom.hex(4) }

    context "when required parameters are present" do
      let(:merged_params) { parameters.merge(model: model, prompt: prompt) }

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(videos).to receive(:rest_create_w_json_params)
          .with(resource: resource, parameters: merged_params)
          .and_return(ret_val)
        expect(videos.create(model: model, prompt: prompt,
                             parameters: parameters)).to eq(ret_val)
      end
    end

    context "when model is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.create(model: nil, prompt: prompt)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when prompt is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.create(model: model, prompt: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(videos).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(videos.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "video_abc123", limit: 20, order: "desc" }
      allow(videos).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(videos.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:video_id) { SecureRandom.hex(4) }

    context "when video_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.retrieve(video_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(videos).to receive(:rest_get)
        .with(resource: resource, id: video_id)
        .and_return(ret_val)
      expect(videos.retrieve(video_id: video_id)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:video_id) { SecureRandom.hex(4) }

    context "when video_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.delete(video_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(videos).to receive(:rest_delete)
        .with(resource: resource, id: video_id)
        .and_return(ret_val)
      expect(videos.delete(video_id: video_id)).to eq(ret_val)
    end
  end

  describe "#content" do
    let(:video_id) { SecureRandom.hex(4) }
    let(:writer) { instance_double(Tempfile) }

    context "when video_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.content(video_id: nil, writer: writer)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get_streamed_download with the expected arguments" do
      allow(videos).to receive(:rest_get_streamed_download)
        .with(resource: [resource, video_id, "content"], writer: writer)
        .and_return(ret_val)
      expect(videos.content(video_id: video_id, writer: writer)).to eq(ret_val)
    end
  end

  describe "#remix" do
    let(:video_id) { SecureRandom.hex(4) }
    let(:prompt) { SecureRandom.hex(4) }

    context "when video_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.remix(video_id: nil, prompt: prompt)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when the required prompt parameter is present" do
      let(:merged_params) { parameters.merge(prompt: prompt) }

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(videos).to receive(:rest_create_w_json_params)
          .with(resource: [resource, video_id, "remix"], parameters: merged_params)
          .and_return(ret_val)
        expect(videos.remix(video_id: video_id, prompt: prompt,
                            parameters: parameters)).to eq(ret_val)
      end
    end

    context "when the required prompt parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          videos.remix(video_id: video_id, prompt: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end
end
