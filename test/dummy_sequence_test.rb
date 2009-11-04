require 'test/unit'
require 'test_helper'

class JdbcOpenEdgeTest <Test::Unit::TestCase

  def setup
    @connection = Person.new.connection
  end

  def test_creation_of_dummy_seq_and_dummy_table_if_not_exist
    drop_sequence
    assert_nothing_raised do
      @connection.send(:create_dummy_sequence)
    end
  end

  private

  def drop_sequence
    begin
      @connection.send(:execute,"drop table pub.dummy_sequence")
    rescue
    end

    begin
      @connection.send(:execute, "drop sequence pub.dummy_sequence")
    rescue
    end
  end
  
end
