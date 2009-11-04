require 'test/unit'
require 'test_helper'

class FindersTest < Test::Unit::TestCase

  def setup
    Types.delete_all
  end

  #Si le champs default de Progress est ? , la valeur de l'objet doit être nil
  def test_object_is_nil_if_default_value_is_null
    t = Types.new
    assert_equal nil,t.integer
    assert_equal nil,t.date
    assert_equal nil,t.datetime
  end
end
