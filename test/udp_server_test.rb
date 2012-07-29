require 'test_helper'

class UdpServerTest < Test::Unit::TestCase
  def setup
    @registry = MetriksServer::Registry.new
    @server = MetriksServer::UdpServer.new(@registry, :port => 30000 + rand(1000))
    @server.start
  end
  
  def teardown
    @server.stop
    @server.join
  end

  def test_data
    # Wait for eventmachine
    thr = Thread.current; EventMachine.next_tick { thr.wakeup }; Thread.stop

    data = Snappy.deflate({ :name => 'a', :client_id => $$, :time => Time.now.to_i, :anything => 'yay' }.to_msgpack)
    socket = UDPSocket.new
    socket.send data, 0, '127.0.0.1', @server.port
    
    sleep 0.1
    
    assert @server.registry.dirty?, @server.registry.inspect
  end
end
