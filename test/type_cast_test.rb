require 'test/unit'
require 'test_helper'

class FindersTest < Test::Unit::TestCase

  def setup
    Types.delete_all
  end

  def test_get_nil_for_integer_if_default_is_null_in_openedge
    t = Types.new()
    assert_equal nil, t.integer
    assert t.save
    assert t = Types.find(:first,:conditions =>['"integer" is null',])
    assert_equal nil, t.integer
  end

end
