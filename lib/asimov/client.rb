require "forwardable"
require "httparty"
require_relative "azure_uri_factory"
require_relative "headers_factory"
require_relative "open_ai_uri_factory"
require_relative "utils/request_options_validator"
require_relative "api_v1/base"
require_relative "api_v1/audio"
require_relative "api_v1/chat"
require_relative "api_v1/completions"
require_relative "api_v1/edits"
require_relative "api_v1/embeddings"
require_relative "api_v1/files"
require_relative "api_v1/finetunes"
require_relative "api_v1/images"
require_relative "api_v1/models"
require_relative "api_v1/moderations"

module Asimov
  ##
  # Asimov::Client is the main class which developers will use to interact with
  # OpenAI.
  ##
  class Client
    extend Forwardable

    attr_reader :api_type, :request_options

    ##
    # Creates a new Asimov::Client. Includes several optional named parameters:
    #
    # api_type - The type of API that this Asimov::Client will use.  If unspecified,
    #            defaults to the application-wide default that defaults to 'open_ai'
    # api_key - The OpenAI API key that this Asimov::Client instance will use.  If unspecified,
    #           defaults to the application-wide configuration
    # organization_id - The OpenAI organization identifier that this Asimov::Client instance
    #                   will use. If unspecified, defaults to the application-wide configuration.
    # request_options - HTTParty request options that will be passed to the underlying network
    #                   client.  Merges (and overrides) global configuration value.
    # openai_api_base - Custom base URI for the API calls made by this client. Defaults to global
    #            configuration value.
    ##
    # rubocop:disable Metrics/ParameterLists
    def initialize(api_type: nil, api_version: nil, api_key: nil,
                   organization_id: HeadersFactory::NULL_ORGANIZATION_ID,
                   request_options: {}, openai_api_base: nil)
      initialize_api_type(api_type, api_version)
      @headers_factory = HeadersFactory.new(@api_type,
                                            api_key,
                                            organization_id)
      @request_options = Asimov.configuration.request_options
                               .merge(Utils::RequestOptionsValidator.validate(request_options))
                               .freeze
      @uri_factory = OpenAIUriFactory.new(@api_type, @api_version, openai_api_base)
    end
    def_delegators :@headers_factory, :api_key, :organization_id, :headers
    def_delegators :@uri_factory, :openai_api_base, :api_version, :resource_singular_uri,
                   :resource_class_uri, :resource_instance_uri

    # rubocop:enable Metrics/ParameterLists

    ##
    # Use the audio method to access API calls in the /audio URI space.
    ##
    def audio
      @audio ||= Asimov::ApiV1::Audio.new(client: self)
    end

    ##
    # Use the chat method to access API calls in the /chat URI space.
    ##
    def chat
      @chat ||= Asimov::ApiV1::Chat.new(client: self)
    end

    ##
    # Use the completions method to access API calls in the /completions URI space.
    ##
    def completions
      @completions ||= Asimov::ApiV1::Completions.new(client: self)
    end

    ##
    # Use the edits method to access API calls in the /edits URI space.
    ##
    def edits
      @edits ||= Asimov::ApiV1::Edits.new(client: self)
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
    # Use the finetunes method to access API calls in the /fine-tunes URI space.
    ##
    def finetunes
      @finetunes ||= Asimov::ApiV1::Finetunes.new(client: self)
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

    def azure?
      ApiType.azure?(api_type)
    end

    private

    def build_uri_factory(openai_api_base)
      @uri_factory = if azure?
                       AzureUriFactory.new(api_type, api_version, openai_api_base)
                     else
                       OpenAIUriFactory.new(api_type, api_version, openai_api_base)
                     end
    end

    def initialize_api_type(api_type, api_version)
      @api_type = Asimov::ApiType.normalize(api_type || Asimov.configuration.api_type)

      raise Asimov::UnknownApiTypeError unless @api_type

      @api_version = api_version || Asimov.configuration.api_version(api_type)
    end
  end
end
