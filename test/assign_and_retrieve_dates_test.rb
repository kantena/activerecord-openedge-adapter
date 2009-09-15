require 'test/unit'
['test_helper','models/types'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class DatesTest < Test::Unit::TestCase

  def setup
    Types.delete_all
  end


  def test_assign_and_retrieve_date_with_string
    date = '12/09/2000'
    t = Types.new
    t.date = date
    assert t.save
    t.reload
     p t.date.inspect
    assert_equal date, t.date
  end

  
  def test_assign_and_retrieve_date_with_date_object
    date = Date.new(2007,12,9)
    t = Types.new
    t.date = date
    assert t.save
    t.reload
    p t.date.strftime("%d/%m/%Y")
    assert_equal date, t.date
  end



end
