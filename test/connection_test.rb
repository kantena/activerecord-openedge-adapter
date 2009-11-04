require 'test/unit'
require 'test_helper'

class ConnectionTest < Test::Unit::TestCase

  def test_establish_connection_to_progress_database
    Person.new
    assert Person.connected?
  end
  
end

  
