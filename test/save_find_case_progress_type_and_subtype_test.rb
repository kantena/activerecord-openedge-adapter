require 'test/unit'

['test_helper','models/types'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class SaveFindForDifferentProgressTypesTest < Test::Unit::TestCase

  def setup
    Types.delete_all
    @t = create_empty_type_and_find_it
  end
 
  def test_with_date
    @t.date = '2009-09-20'
    assert @t.save
    @t = Types.find :first
    assert_equal '2009-09-20', @t.date.to_s(:db)
  end

  def test_with_decimal
    test_with('decimal',0,3.6)
  end

  def test_with_logical
    test_with('logical',false,true)
  end

  def test_with_date_time
    @t.datetime = '2009-09-20 20:30:20'
    assert @t.save
    @t.reload
    assert_equal '2009-09-20 20:30:20', @t.datetime.to_s(:db)
  end
  
  def test_with_date_time_tz
    date_tz = Time.now
    @t['datetime-tz'] = date_tz
    assert @t.save
    @t.reload
    assert_equal date_tz.to_s, @t['datetime-tz'].to_s
  end

  def test_with_float
    test_with('float',0,3.677888)
  end

  def test_with_char
    test_with('char','','A')
  end

  def test_with_chars
    test_with('chars','','foo')
  end

  def test_with_extended_chars
    @t = create_empty_type_and_find_it
    assert_equal [nil,'','',''],@t['extended-chars']
    @t['extended-chars'][1] = 'ABCD'
    @t['extended-chars'][2] = 'EFGH'
    assert @t.save
    @t = Types.find :first
    assert_equal 'ABCD', @t['extended-chars'][1]
    assert_equal 'EFGH', @t['extended-chars'][2]
  end

  def test_with_extended_numeric

  end

  private
  
  def test_with(attr,initial_value,affected_value,expected_value=affected_value)
    @t = create_empty_type_and_find_it
    assert_equal initial_value,@t[attr]
    @t[attr] = affected_value
    assert @t.save
    @t = Types.find :first
    assert_equal expected_value, @t[attr]
    
  end

  def create_empty_type_and_find_it
    assert Types.new.save
    Types.find :first
  end
  
end
