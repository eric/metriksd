require 'active_support/core_ext/hash'

module MetriksServer
  class Data
    attr_reader :time, :client_id, :name, :payload

    def initialize(data)
      data = HashWithIndifferentAccess.new(data)

      unless @time = data.delete(:time)
        raise ArgumentError, "No 'time' was found"
      end

      unless @client_id = data.delete(:client_id)
        raise ArgumentError, "No 'client_id' was found"
      end

      unless @name = data.delete(:name)
        raise ArgumentError, "No 'name' was found"
      end

      @payload = data
    end

    def [](key)
      @payload[key]
    end
  end
end
