require "forwardable"
require "httparty"
require_relative "headers_factory"
require_relative "api_v1/base"
require_relative "api_v1/completions"
require_relative "api_v1/edits"
require_relative "api_v1/embeddings"
require_relative "api_v1/files"
require_relative "api_v1/finetunes"
require_relative "api_v1/images"
require_relative "api_v1/models"
require_relative "api_v1/moderations"

module Asimov
  class Client
    extend Forwardable

    URI_BASE = "https://api.openai.com".freeze

    attr_reader :access_token, :organization_id, :api_version

    def initialize(access_token: nil, organization_id: HeadersFactory::NULL_ORGANIZATION_ID)
      @headers_factory = HeadersFactory.new(access_token,
                                            organization_id)
    end
    def_delegators :@headers_factory, :access_token, :organization_id, :headers

    def completions
      @completions ||= Asimov::ApiV1::Completions.new(client: self)
    end

    def edits
      @edits ||= Asimov::ApiV1::Edits.new(client: self)
    end

    def embeddings
      @embeddings ||= Asimov::ApiV1::Embeddings.new(client: self)
    end

    def files
      @files ||= Asimov::ApiV1::Files.new(client: self)
    end

    def finetunes
      @finetunes ||= Asimov::ApiV1::Finetunes.new(client: self)
    end

    def images
      @images ||= Asimov::ApiV1::Images.new(client: self)
    end

    def models
      @models ||= Asimov::ApiV1::Models.new(client: self)
    end

    def moderations
      @moderations ||= Asimov::ApiV1::Moderations.new(client: self)
    end
  end
end
