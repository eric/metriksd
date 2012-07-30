module Metriksd
  class Timeslice
    attr_reader :time

    def initialize(time)
      @time    = time
      @mutex   = Mutex.new
      @dirty   = false
      @records = {}
    end
    
    def dirty?
      @mutex.synchronize do
        @dirty
      end
    end

    def flush
      @mutex.synchronize do
        @dirty = false
        @records.values
      end
    end
    
    def push(data)
      @mutex.synchronize do
        @records["#{data.client_id}/#{data.name}"] = data
        @dirty = true
      end
    end
    alias_method :<<, :push
  end
end
