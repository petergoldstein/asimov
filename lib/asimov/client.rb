require "forwardable"
require "httparty"
require_relative "headers_factory"
require_relative "utils/request_options_validator"
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
  ##
  # Asimov::Client is the main class which developers will use to interact with
  # OpenAI.
  ##
  class Client
    extend Forwardable

    attr_reader :api_key, :organization_id, :api_version, :request_options, :openai_api_base

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
                   request_options: {}, openai_api_base: nil)
      @headers_factory = HeadersFactory.new(api_key,
                                            organization_id)
      @request_options = Asimov.configuration.request_options
                               .merge(Utils::RequestOptionsValidator.validate(request_options))
                               .freeze
      initialize_openai_api_base(openai_api_base)
    end
    def_delegators :@headers_factory, :api_key, :organization_id, :headers

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
