require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/jdbc_adapter/jdbc_openedge')
['test_helper','models/person','models/types', '../lib/jdbc_adapter/jdbc_openedge'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end
class JdbcOpenEdgeTest <Test::Unit::TestCase
  include JdbcSpec
  include OpenEdge

  def test_adapter_matcher
    assert !OpenEdge.adapter_matcher("jdbc:mysql")
    assert OpenEdge.adapter_matcher("jdbc:datadirect:openedge://20001")
  end

  def test_quote_column_name
    assert_equal '"codtab"',quote_column_name("codtab")
    assert_equal '"codsoc-cli"',quote_column_name("codsoc-cli")
  end

  def test_quote_table_name
    assert_equal '"'+DEFAULT_TABLE_PREFIX+'"."appros"',quote_table_name("appros")
    assert_equal '"pub"."appros"',quote_table_name("pub.appros")
  end

  def test_doublequote_quotes_in_sql_statements
    p = Person.new
    p.name = "Eléonor d'iroise"
    assert p.save
    p.reload
    assert_equal "Eléonor d'iroise", p.name
  end

  def test_save_numeric_nil
    t = Types.new
    t.integer = nil
    assert t.save
    t.reload
    assert_equal nil, t.integer
  end

  def test_quote_value
    z = Date.today
    z = nil
    assert_equal "2",quote_value(2)
    assert_equal '0',quote_value(false)
    assert_equal '1',quote_value(true)
    assert_equal 'NULL',quote_value(z)
  end
end
