module Asimov
  module ApiV1
    ##
    # Mixin providing automatic retry with exponential backoff for
    # transient API errors (rate limits, overload, service unavailable).
    ##
    module Retryable
      RETRYABLE_ERRORS = [
        Asimov::RateLimitError,
        Asimov::ApiOverloadedError,
        Asimov::ServiceUnavailableError
      ].freeze

      MAX_BACKOFF = 60
      private_constant :MAX_BACKOFF

      private

      def with_retries
        attempts = 0
        begin
          yield
        rescue *RETRYABLE_ERRORS => e
          attempts += 1
          raise e if attempts > max_retries

          sleep(backoff_delay(attempts))
          retry
        end
      end

      def max_retries
        Asimov.configuration.max_retries
      end

      def backoff_delay(attempt)
        [(2**attempt) + rand(0.0..0.5), MAX_BACKOFF].min
      end
    end
  end
end
