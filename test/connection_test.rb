require 'test/unit'
require File.join(File.dirname(__FILE__), 'models/magasin')


class ConnectionTest < Test::Unit::TestCase

  def test_establish_connection_to_progress_database
    Magasin.new
    assert Magasin.connected?
  end
end

  
