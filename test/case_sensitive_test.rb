require 'test/unit'
['test_helper','models/types'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class CaseSensitiveTets < Test::Unit::TestCase

  def test_column_chars_in_types_is_sensitive_jdbc_column
   # assert column(Types,'chars').case_sensitive?
  end

  def test_column_char_in_types_is_insensitive_jdbc_column

  end
  
end
