require 'metriks_server/data'
require 'metriks_server/timeslice'

module MetriksServer
  class Registry
    attr_reader :interval, :window

    def initialize(options = {})
      @interval = options[:interval] || 60
      @window   = options[:window]   || 10 * @interval

      @mutex = Mutex.new

      @timeslices = Hash.new do |h,k|
        h[k] = Timeslice.new(k)
      end
    end
    
    def dirty?
      @timeslices.any? { |_, t| t.dirty? }
    end
    
    def push(data)
      t = rounded_time(data.time)
      timeslice = nil

      @mutex.synchronize do
        @timeslices[t] << data
      end
    end
    alias_method :<<, :push

    def dirty_timeslices
      trim

      @mutex.synchronize do
        @timeslices.values.select { |t| t.dirty? }
      end
    end
    
    def rounded_time(time)
      time = time.to_i
      time - (time % @interval)
    end
    
    def trim
      oldest_time = Time.now.to_i - @window

      @mutex.synchronize do
        @timeslices.delete_if do |time, _|
          time < oldest_time
        end
      end
    end
  end
end
