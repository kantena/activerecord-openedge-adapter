require 'test/unit'
['test_helper','models/foo'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end
class FooTest < Test::Unit::TestCase

  def setup
    Person.delete_all
  end

  def test_assign_and_retrieve_date_with_string
    date = '12/09/2000'
    p = Person.new
    p.name = "toto"
    p.birthday = date
    assert p.save
    p.reload
    assert_equal date, p.birthday
  end

  def test_assign_and_retrieve_date_with_time_now
    date = Time.now
    p = Person.new
    p.name = "toto"
    p.birthday = date
    assert p.save
    p.reload
    assert_equal date, p.birthday
  end

  def test_assign_and_retrieve_date_with_date_object
    date = Date.new(2007)
    p = Person.new
    p.name = "toto"
    p.birthday = date
    assert p.save
    p.reload
    assert_equal date, p.birthday
  end

end
