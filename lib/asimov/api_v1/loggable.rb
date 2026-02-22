module Asimov
  module ApiV1
    ##
    # Mixin providing request/response logging when a logger is configured.
    ##
    module Loggable
      private

      def log_request
        return yield unless logger

        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = yield
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

        log_completion(result, duration)
        result
      end

      def log_completion(resp, duration)
        return unless resp.respond_to?(:request)

        req = resp.request
        method = req.http_method.name.split("::").last.upcase
        path = req.path.to_s
        timing = format("%.3fs", duration)
        logger.send(log_level, "[Asimov] #{method} #{path} -> #{resp.code} (#{timing})")
      rescue StandardError
        nil
      end

      def logger
        Asimov.configuration.logger
      end

      def log_level
        Asimov.configuration.log_level || :info
      end
    end
  end
end
