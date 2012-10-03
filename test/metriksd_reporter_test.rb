require 'test_helper'
require 'metriksd/config'
require 'metriksd_reporter'
require 'metriks'

class MetriksdReporterTest < Test::Unit::TestCase
  def test_working_config
    @port = 39283

    @server_config = Metriksd::Config.new

    @server_config.load :registry => {
      :ignore_current_timeslice => false,
      :reporter => {
        :type => 'librato_metrics',
        :email => 'a@b.com',
        :api_key => 'a' * 10
      },
      :server => {
        :type => 'udp',
        :port => @port
      }  
    }

    @server_config.start

    # Wait for eventmachine
    thr = Thread.current; EventMachine.next_tick { thr.wakeup }; Thread.stop

    @server_reporter = @server_config.reporters.first
    @server_reporter.client.persistence = :test
    @server_persister = @server_reporter.queue.persister

    @client_registry = Metriks::Registry.new
    @client_reporter = MetriksdReporter.new(:host => '127.0.0.1', :port => @port,
      :registry => @client_registry, :extras => { :source => Socket.gethostname })

    @client_reporter.start
    @client_registry.timer('test.timer').update(5.3)
    @client_registry.histogram('test.histogram').update(5.3)

    @client_reporter.flush
    @client_reporter.stop

    @server_config.stop
    @server_config.join

    assert_not_nil @server_persister.persisted, @server_persister.inspect
    assert @server_persister.persisted.length == 1, @server_persister.persisted.inspect
  end
end
