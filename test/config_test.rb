require 'test_helper'
require 'metriksd/config'

class ConfigTest < Test::Unit::TestCase
  def setup
    @config = Metriksd::Config.new
  end
  
  def test_broken_config
    assert_raises ArgumentError do
      @config.load(:registry => {})
    end
  end

  def test_working_config
    @config.load :registry => {
      :reporter => {
        :type => 'librato_metrics',
        :email => 'a@b.com',
        :api_key => 'a' * 10
      },
      :server => {
        :type => 'udp',
        :port => 39283
      }  
    }

    @config.start
    @config.stop
    @config.join
  end
end
