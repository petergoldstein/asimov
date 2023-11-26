module Asimov
  ##
  # Asimov::ApiType specifies the type of API being used (OpenAI, Azure, etc.) which
  # impacts URI structure and authentication.
  ##
  class ApiType
    API_TYPES = %w[
      azure
      open_ai
      azure_ad
    ].freeze
    private_constant :API_TYPES

    ALIASES = {
      "openai" => "open_ai",
      "azuread" => "azure_ad"
    }.freeze
    private_constant :ALIASES

    API_TYPES.each do |k|
      const_set k.upcase, k
    end

    DEFAULT = OPEN_AI

    DEFAULT_AZURE_VERSION = "2022-12-01".freeze

    def self.normalize(key)
      # Use the default if no type is specified
      return DEFAULT if key.nil?

      key = key.downcase
      dealiased_key = ALIASES[key] || key
      return dealiased_key if API_TYPES.include?(dealiased_key)
    end

    def self.bearer_auth?(key)
      [ApiType::OPEN_AI, ApiType::AZURE_AD].include?(key)
    end

    def self.azure?(key)
      [ApiType::AZURE, ApiType::AZURE_AD].include?(key)
    end
  end
end
