require 'socket'
require 'logger'
require 'snappy'
require 'msgpack'

require 'metriks_server/registry'

module MetriksServer
  class UdpServer
    attr_reader :logger, :port, :host, :registry

    def initialize(registry, options = {})
      missing_keys = %w(port) - options.keys.map(&:to_s)
      unless missing_keys.empty?
        raise ArgumentError, "Missing required options: #{missing_keys * ', '}"
      end

      @registry = registry
      @port     = options[:port]
      @host     = options[:host]   || '0.0.0.0'
      @logger   = options[:logger] || Logger.new(STDERR)
      @recvbuf  = options[:recvbuf] || 1024 * 1024

      @unpacker = MessagePack::Unpacker.new
    end
    
    def start
      @socket ||= UDPSocket.new.tap do |s|
        s.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, @recvbuf)
        s.bind(@host, @port)
      end
      
      @thread ||= Thread.new do
        while @socket
          begin
            data, sender = @socket.recvfrom(10000)
            unmarshal(data)
          rescue IOError
            # It's likely our socket was closed on us
          rescue => e
            logger.error "Error in metriks server: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
          end
        end
      end
    end
    
    def stop
      if @socket
        @socket.close
        @socket = nil
      end
      
      if @thread
        @thread.join
        @thread = nil
      end
    end

    def join
      if @thread
        @thread.join
      end
    end
    
    def unmarshal(data)
      @unpacker.feed_each(Snappy.inflate(data)) do |payload|
        @registry << Data.new(payload)
      end
    end
  end
end
