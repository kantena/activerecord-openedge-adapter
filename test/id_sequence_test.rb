require 'test/unit'
['test_helper','../lib/jdbc_adapter/jdbc_openedge','models/person' ].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class IdTest < Test::Unit::TestCase
  include JdbcSpec
  include OpenEdge
 
  def setup
    @connection = Person.connection
    assert Person.delete_all
  end

  def test_get_next_sequence_value_incremented_by_one
    current_value = current_sequence_value
    assert_equal current_value + 1,  @connection.next_sequence_value
    assert_equal current_value + 1 , current_sequence_value
  end
 
  def test_retrieve_id_and_id_successives
    alphonse, pierre = create_person('Alphonse'), create_person('Pierre')
    assert !alphonse.id.nil? &&  !pierre.id.nil?
    assert_equal alphonse.id + 1, pierre.id
  end

  private
  def current_sequence_value
    sql = "select pub.dummy_sequence.currval from pub.dummy_sequence"
    res = @connection.select_one(sql)
    res.nil? ? 0 : res['sequence_current'].to_i
  end

end
