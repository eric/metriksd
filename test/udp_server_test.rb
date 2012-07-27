require 'test_helper'

class UdpServerTest < Test::Unit::TestCase
  def setup
    @registry = MetriksServer::Registry.new
    @server = MetriksServer::UdpServer.new(@registry, :port => 31000 + rand(1000))
    @server.start
  end
  
  def teardown
    @server.stop
  end

  def test_data
    data = Snappy.deflate({ :client_id => $$, :time => Time.now.to_i, :anything => 'yay' }.to_msgpack)
    socket = UDPSocket.new
    socket.send data, 0, '127.0.0.1', @server.port
    
    sleep 0.25
    
    assert @server.registry.dirty?, @server.registry.inspect
  end
end
