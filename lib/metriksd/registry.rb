require 'metriksd/data'
require 'metriksd/timeslice'

module Metriksd
  class Registry
    attr_reader :interval, :window

    def initialize(options = {})
      @interval = options[:interval] || 60
      @window   = options[:window]   || 10 * @interval

      @ignore_current_timeslice = options.fetch(:ignore_current_timeslice, true)

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
        if @ignore_current_timeslice
          current_time = rounded_time(Time.now)
        end

        @timeslices.values.select do |t|
          t.dirty? && (!current_time || current_time != t.time)
        end
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
