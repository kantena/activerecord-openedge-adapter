require 'test/unit'

['test_helper','models/types'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class SaveFindForDifferentProgressTypesTest < Test::Unit::TestCase

  def setup
    Types.delete_all
    @t = create_type
  end
 
  def test_with_date
    @t.date = '2009-09-20'
    assert @t.save
    assert_equal '2009-09-20', @t.reload.date.to_s(:db)
  end

  def test_with_decimal
    assert_equal 0, @t.decimal
    @t.decimal = 3.6
    assert @t.save
    assert_equal 3.6, @t.reload.decimal
  end

  def test_with_logical
    assert_equal false, @t.logical
    @t.logical = true
    assert @t.save
    assert_equal true, @t.reload.logical
  end

  def test_with_date_time
    @t.datetime = '2009-09-20 20:30:20'
    assert @t.save
    assert_equal '2009-09-20 20:30:20',  @t.reload.datetime.to_s(:db)
  end
  
  def test_with_date_time_tz
    date_tz = Time.now
    @t['datetime-tz'] = date_tz
    assert @t.save
    assert_equal date_tz.to_s, @t.reload['datetime-tz'].to_s
  end

  def test_with_float
    assert_equal nil, @t.float
    @t.float = 3.677888
    assert @t.save
    assert_equal 3.677888, @t.reload.float
  end

  def test_with_char
    assert_equal nil, @t.char
    @t.char = 'A'
    assert @t.save
    assert_equal 'A', @t.reload.char
  end

  def test_with_chars
    assert_equal nil, @t.chars
    @t.chars = 'foo'
    assert @t.save
    assert_equal 'foo', @t.reload.chars
  end

  def test_with_extended_chars
    assert_equal [nil,'','',''],@t['extend_chars']
    @t['extend_chars'][1] = 'ABCD'
    @t['extend_chars'][2] = 'EFGH'
    assert @t.save
    @t = Types.find :first
    assert_equal 'ABCD', @t['extend_chars'][1]
    assert_equal 'EFGH', @t['extend_chars'][2]
  end

end
