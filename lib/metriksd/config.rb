require 'metriksd/registry'
require 'metriksd/udp_server'
require 'metriksd/librato_metrics_reporter'

module Metriksd
  class Config
    attr_reader :servers, :reporters

    def initialize
      @servers   = []
      @reporters = []
    end

    def load_file(file)
      load(YAML::load_file(file).with_indifferent_access)
    end

    def load(config)
      config = config.with_indifferent_access

      registries = [ config[:registry] ].flatten.compact
      if registries.respond_to?(:to_hash)
        registries = registries.to_hash.values
      end

      registries.each do |registry_config|
        registry_config = registry_config.with_indifferent_access

        reporter_config = registry_config.delete(:reporter)
        unless reporter_config
          raise ArgumentError, "Must provide a 'reporter'"
        end
        reporter_config = reporter_config.with_indifferent_access

        server_config = registry_config.delete(:server)
        unless server_config
          raise "Must provide a 'server'"
        end
        server_config = server_config.with_indifferent_access

        registry = Metriksd::Registry.new(registry_config)

        @reporters << reporter_class(reporter_config.delete(:type)).new(registry, reporter_config)
        @servers   << server_class(server_config.delete(:type)).new(registry, server_config)
      end
    end

    def start
      (@servers + @reporters).each do |t|
        t.start
      end
    end

    def stop
      (@servers + @reporters).each do |t|
        t.stop
      end
    end

    def join
      (@servers + @reporters).each do |t|
        t.join
      end
    end

    def reporter_class(type)
      case type.to_s
      when 'librato_metrics'
        Metriksd::LibratoMetricsReporter
      when '', nil
        raise "No reporter 'type' was specified"
      else
        raise "Unknown reporter 'type': #{type.inspect}"
      end
    end

    def server_class(type)
      case type.to_s
      when 'udp'
        Metriksd::UdpServer
      when '', nil
        raise "No server 'type' was specified"
      else
        raise "Unknown server 'type': #{type.inspect}"
      end
    end
  end
end
