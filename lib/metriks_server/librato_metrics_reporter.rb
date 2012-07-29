require 'librato/metrics'

module MetriksServer
  class LibratoMetricsReporter
    attr_reader :client, :queue

    def initialize(registry, options = {})
      missing_keys = %w(email api_key) - options.keys.map(&:to_s)
      unless missing_keys.empty?
        raise ArgumentError, "Missing required options: #{missing_keys * ', '}"
      end

      @registry = registry
      @client = Librato::Metrics::Client.new
      @client.authenticate options[:email], options[:api_key]
      @queue = @client.new_queue

      @interval        = options[:interval] || @registry.interval
      @intervel_offset = options[:interval_offset] || 2
    end

    def start
      @thread = Thread.new do
        Thread.current.abort_on_exception = true

        @running = true

        while @running
          sleep_until_deadline
          flush
        end
      end
    end

    def stop
      @running = false
    end

    def join
      if @thread
        @thread.join
      end
    end

    def flush
      timeslices = @registry.dirty_timeslices

      timeslices.each do |timeslice|
        rollup = MetriksServer::LibratoMetricsReporter::TimesliceRollup.new(timeslice)
        @queue.add rollup.to_hash
      end

      unless queue.empty?
        @queue.submit
      end
    end

    def sleep_until_deadline
      now          = Time.now.to_f
      rounded      = now - (now % @interval)
      next_rounded = rounded + @interval + @intervel_offset
      sleep_time   = next_rounded - Time.now.to_f

      # Allow this to be interrupted
      while sleep_time > 0 && @running
        s = [ sleep_time, 1 ].min

        sleep(s)

        sleep_time = next_rounded - Time.now.to_f
      end
    end
  end
end

require 'metriks_server/librato_metrics_reporter/timeslice_rollup'
