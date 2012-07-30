require 'socket'
require 'eventmachine'
require 'logger'
require 'snappy'
require 'msgpack'

require 'metriksd/registry'

module Metriksd
  class UdpServer
    class Handler < EventMachine::Connection
      def initialize(proc)
        @proc = proc
        super
      end

      def receive_data(data)
        @proc.call(data)
      end
    end

    attr_reader :logger, :port, :host, :registry

    def initialize(registry, options = {})
      missing_keys = %w(port) - options.keys.map(&:to_s)
      unless missing_keys.empty?
        raise ArgumentError, "Missing required options: #{missing_keys * ', '}"
      end

      @registry = registry
      @port     = options[:port]
      @host     = options[:host]    || '0.0.0.0'
      @logger   = options[:logger]  || Logger.new(STDERR)
      @recvbuf  = options[:recvbuf] || 1024 * 1024

      @unpacker = MessagePack::Unpacker.new
    end
    
    def start
      unless EventMachine.reactor_running?
        Thread.new do
          EventMachine.epoll  = true if EventMachine.epoll?
          EventMachine.kqueue = true if EventMachine.kqueue?
          EventMachine.run
        end
      end

      EventMachine.next_tick do
        handler = proc do |data|
          begin
            unmarshal(data)
          rescue => e
            logger.error "Error in metriks server: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
          end
        end

        EventMachine.open_datagram_socket(@host, @port, Handler, handler)
      end
    end
    
    def stop
      EventMachine.stop
    end

    def join
      if EventMachine.reactor_thread?
        EventMachine.reactor_thread.join
      end
    end
    
    def unmarshal(data)
      @unpacker.feed_each(Snappy.inflate(data)) do |payload|
        @registry << Data.new(payload)
      end
    end
  end
end
