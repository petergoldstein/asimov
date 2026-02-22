require "forwardable"
require "httparty"
require_relative "headers_factory"
require_relative "utils/request_options_validator"
require_relative "api_v1/base"
require_relative "api_v1/audio"
require_relative "api_v1/batches"
require_relative "api_v1/chat"
require_relative "api_v1/conversations"
require_relative "api_v1/embeddings"
require_relative "api_v1/files"
require_relative "api_v1/fine_tuning"
require_relative "api_v1/images"
require_relative "api_v1/models"
require_relative "api_v1/moderations"
require_relative "api_v1/realtime"
require_relative "api_v1/responses"
require_relative "api_v1/uploads"
require_relative "api_v1/vector_stores"

module Asimov
  ##
  # Asimov::Client is the main class which developers will use to interact with
  # OpenAI.
  ##
  class Client
    extend Forwardable

    attr_reader :api_version, :request_options, :openai_api_base

    ##
    # Creates a new Asimov::Client. Includes several optional named parameters:
    #
    # api_key - The OpenAI API key that this Asimov::Client instance will use.  If unspecified,
    #           defaults to the application-wide configuration
    # organization_id - The OpenAI organization identifier that this Asimov::Client instance
    #                   will use. If unspecified, defaults to the application-wide configuration.
    # request_options - HTTParty request options that will be passed to the underlying network
    #                   client.  Merges (and overrides) global configuration value.
    # openai_api_base - Custom base URI for the API calls made by this client. Defaults to global
    #            configuration value.
    ##
    def initialize(api_key: nil, organization_id: HeadersFactory::NULL_ORGANIZATION_ID,
                   project_id: HeadersFactory::NULL_PROJECT_ID,
                   request_options: {}, openai_api_base: nil)
      @headers_factory = HeadersFactory.new(api_key,
                                            organization_id,
                                            project_id)
      @request_options = Asimov.configuration.request_options
                               .merge(Utils::RequestOptionsValidator.validate(request_options))
                               .freeze
      initialize_openai_api_base(openai_api_base)
    end
    def_delegators :@headers_factory, :api_key, :organization_id, :project_id, :headers

    ##
    # Use the audio method to access API calls in the /audio URI space.
    ##
    def audio
      @audio ||= Asimov::ApiV1::Audio.new(client: self)
    end

    ##
    # Use the batches method to access API calls in the /batches URI space.
    ##
    def batches
      @batches ||= Asimov::ApiV1::Batches.new(client: self)
    end

    ##
    # Use the chat method to access API calls in the /chat URI space.
    ##
    def chat
      @chat ||= Asimov::ApiV1::Chat.new(client: self)
    end

    ##
    # Use the conversations method to access API calls in the /conversations URI space.
    ##
    def conversations
      @conversations ||= Asimov::ApiV1::Conversations.new(client: self)
    end

    ##
    # Use the embeddings method to access API calls in the /embeddings URI space.
    ##
    def embeddings
      @embeddings ||= Asimov::ApiV1::Embeddings.new(client: self)
    end

    ##
    # Use the files method to access API calls in the /files URI space.
    ##
    def files
      @files ||= Asimov::ApiV1::Files.new(client: self)
    end

    ##
    # Use the fine_tuning method to access API calls in the /fine_tuning/jobs URI space.
    ##
    def fine_tuning
      @fine_tuning ||= Asimov::ApiV1::FineTuning.new(client: self)
    end

    ##
    # Use the images method to access API calls in the /images URI space.
    ##
    def images
      @images ||= Asimov::ApiV1::Images.new(client: self)
    end

    ##
    # Use the models method to access API calls in the /models URI space.
    ##
    def models
      @models ||= Asimov::ApiV1::Models.new(client: self)
    end

    ##
    # Use the moderations method to access API calls in the /moderations URI space.
    ##
    def moderations
      @moderations ||= Asimov::ApiV1::Moderations.new(client: self)
    end

    ##
    # Use the realtime method to access the WebSocket-based Realtime API.
    ##
    def realtime
      @realtime ||= Asimov::ApiV1::Realtime.new(client: self)
    end

    ##
    # Use the responses method to access API calls in the /responses URI space.
    ##
    def responses
      @responses ||= Asimov::ApiV1::Responses.new(client: self)
    end

    ##
    # Use the uploads method to access API calls in the /uploads URI space.
    ##
    def uploads
      @uploads ||= Asimov::ApiV1::Uploads.new(client: self)
    end

    ##
    # Use the vector_stores method to access API calls in the /vector_stores URI space.
    ##
    def vector_stores
      @vector_stores ||= Asimov::ApiV1::VectorStores.new(client: self)
    end

    private

    def initialize_openai_api_base(openai_api_base)
      @openai_api_base = openai_api_base || Asimov.configuration.openai_api_base
      if @openai_api_base
        @openai_api_base = HTTParty.normalize_base_uri(@openai_api_base)
      else
        raise Asimov::MissingBaseUriError,
              "No API Base URI was provided for this client."
      end
    end
  end
end
