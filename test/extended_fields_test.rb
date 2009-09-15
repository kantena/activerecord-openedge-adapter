require 'test/unit'

['test_helper','../lib/jdbc_adapter/jdbc_openedge','models/person','models/pet'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class ExtendedFieldsTest < Test::Unit::TestCase

  def setup
    @connection = Person.connection
  end
  
  def test_get_extended_columns
    extended_cols = @connection.extended_columns("pub.people")
    assert_equal 1, extended_cols.size
    assert_equal 'adress', extended_cols.first['col']
  end

  def test_extended_column?
    Person.columns.each do |col|
      if col.name == "adress" 
        assert col.extended?
      else
        assert !col.extended?
      end
    end
  end

  def test_from_extended_column?
    Person.columns.each do |col|
      if col.name =~/__\d+$/
        assert col.from_extended_column?
      else
        assert !col.from_extended_column?
      end
    end
  end

  def test_extended_size_of_extended_column
    Person.columns.each do |col|
      if col.name == "adress"
        assert_equal 8,col.extended_size
      end
    end
  end

  def test_attributes
    p = Person.new
    assert_equal 3, p.attributes.size
    assert p.adress
    assert p.name
  end

  private
  def generate_ext_fields_names(name,ext_value)
    (1..ext_value).map { |i| "#{name}__"+i.to_s}
  end
 
end

