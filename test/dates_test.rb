require 'test/unit'
require 'test_helper'


class DatesTest < Test::Unit::TestCase

  def setup
    Types.delete_all
  end

  def test_assign_and_retrieve_date_with_date_object
    date = Date.today
    t = Types.new
    t.date = date
    p t.inspect
    assert t.save
    t.reload
    assert_equal date, t.date
  end

  def test_assign_and_retrieve_date_with_string
    date = '2009-10-30'
    t = Types.new
    t.date = date
    assert t.save
    t.reload
    assert_equal date, t.date.to_s(:db)
  end

  def test_assign_and_retrieve_date_with_time_to_date
    date = Time.now.to_date
    t = Types.new
    t.date = date
    assert t.save
    t.reload
    assert_equal date, t.date
  end

end
