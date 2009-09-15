require 'test/unit'
require 'jdbc_adapter'
require File.join(File.dirname(__FILE__), '../lib/active_record/connection_adapters/connection_adapter')

class DatabaseStatementsTest < Test::Unit::TestCase
  include ActiveRecord::ConnectionAdapters::DatabaseStatements
 
  
  def test_add_limit_offset
    sql = "SELECT * FROM TABLE"
    sql_with_limit = "SELECT TOP 5 * FROM TABLE"
    assert_equal sql_with_limit, add_limit_offset!(sql,:limit => 5)
  end

  
  
end
