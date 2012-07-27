require 'metriks_server/config'
require 'optparse'

module MetriksServer
  class Cli
    def initialize(argv)
      @argv = argv.dup
    end

    def parse
      config_file = nil

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options]"

        opts.on("-c", "--config FILE", "Read configuration file") do |v|
          config_file = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit(1)
        end

        opts.on_tail("--version", "Show version") do
          puts MetriksServer::VERSION
          exit(0)
        end
      end

      rest = opts.parse(@argv)

      unless config_file
        puts "Error: config file must be specified\n\n"
        puts opts
        exit(1)
      end

      config = MetriksServer::Config.new
      config.load_file(config_file)
      config.start
      config.join
    rescue Interrupt
      exit(0)
    ensure
      if config
        config.stop
        config.join
      end
    end
  end
end
