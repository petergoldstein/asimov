module Asimov
  module ApiV1
    ##
    # Translates errors that are generated by Net::HTTP into Asimov::NetworkErrors
    # or a specific subclass to allow better handling by clients of the library.
    ##
    class NetworkErrorTranslator
      # rubocop:disable Metrics/MethodLength

      ##
      # Translates an original error generated by the underlying network
      # stack to an Asimov::NetworkError or a specific subclass,
      # preserving the message from the original error.
      ##
      def self.translate(orig_error)
        case orig_error
        when Net::OpenTimeout
          raise Asimov::OpenTimeout, orig_error.message
        when Net::ReadTimeout
          raise Asimov::ReadTimeout, orig_error.message
        when Net::WriteTimeout
          raise Asimov::WriteTimeout, orig_error.message
        when Timeout::Error, Errno::ETIMEDOUT
          raise Asimov::TimeoutError, orig_error.message
        else
          # Errno::EINVAL, Errno::ECONNRESET, EOFError,
          # Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
          raise Asimov::NetworkError, orig_error.message
        end
      end

      # rubocop:enable Metrics/MethodLength
    end
  end
end
