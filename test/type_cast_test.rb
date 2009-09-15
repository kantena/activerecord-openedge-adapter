require 'test/unit'
['test_helper','models/types'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end
class FindersTest < Test::Unit::TestCase

  def setup
    Types.delete_all
  end

  def test_get_nil_for_integer_if_default_is_question_mark_in_progress
    t = Types.new()
    assert_equal nil, t.integer
    assert t.save
    assert t = Types.find(:first,:conditions =>['"integer" is null',])
    assert_equal nil, t.integer
  end

 

end
