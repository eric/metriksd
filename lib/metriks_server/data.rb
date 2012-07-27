require 'active_support/core_ext/hash'

module MetriksServer
  class Data
    attr_reader :time, :client_id, :payload

    def initialize(data)
      data = HashWithIndifferentAccess.new(data)

      unless @time = data.delete(:time)
        raise ArgumentError, "No 'time' was found"
      end

      unless @client_id = data.delete(:client_id)
        raise ArgumentError, "No 'client_id' was found"
      end

      @payload = data
    end
  end
end