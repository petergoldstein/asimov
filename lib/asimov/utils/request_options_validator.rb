require "json"

module Asimov
  module Utils
    ##
    # Validates a set of request options that are passed to the application
    # configuration or on Asimov::Client initialization. Ensures that the
    # value is a hash, that all keys are symbols, and that all keys correspond
    # to legitimate options (typically relating to network behavior).  Currently
    # does not validate the option values.
    ##
    class RequestOptionsValidator
      # This is taken from HTTParty
      ALLOWED_OPTIONS = %i[timeout open_timeout read_timeout write_timeout local_host local_port
                           verify verify_peer ssl_ca_file ssl_ca_path ssl_version ciphers
                           http_proxyaddr http_proxyport http_proxyuser http_proxypass].freeze

      ##
      # Validates that the options are allowed request
      # options.  Currently checks the keys - both that they are symbols and that
      # they are allowed options.  Does not validate values.
      #
      # Only entry point for this class.
      #
      #  @param [Hash] options the set of request options to validate
      ##
      def self.validate(options)
        unless options.is_a?(Hash)
          raise Asimov::ConfigurationError,
                "Request options must be a hash"
        end

        check_unsupported_options(generate_unsupported_options(options))
        options
      end

      def self.generate_unsupported_options(options)
        unsupported_options = []
        options.each_key do |k|
          check_symbol(k)
          unsupported_options << k unless supported_option?(k)
        end
        unsupported_options
      end
      private_class_method :generate_unsupported_options

      def self.check_unsupported_options(unsupported_options)
        return if unsupported_options.empty?

        quoted_keys = unsupported_options.map { |k| "'#{k}'" }
        raise Asimov::ConfigurationError,
              "The options #{quoted_keys.join(',')} are not supported."
      end
      private_class_method :check_unsupported_options

      def self.supported_option?(key)
        ALLOWED_OPTIONS.include?(key)
      end

      def self.check_symbol(key)
        return if key.is_a?(Symbol)

        raise Asimov::ConfigurationError,
              "Request options keys must be symbols.  The key '#{key}' is not a symbol."
      end
      private_class_method :check_symbol
    end
  end
end
