require 'test/unit'
['test_helper','models/person','models/magasin'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end
class FindersTest < Test::Unit::TestCase

  def setup
    Person.delete_all
  end
  
  def test_find_all_with_limit
    assert_equal 2,Magasin.find(:all,:limit => 2).size
    assert_equal 1,Magasin.find(:all,:limit => 1).size
    assert_equal Magasin.count,Magasin.find(:all,:limit => Magasin.count + 10).size
  end

  def test_find_first
    assert_equal 1,[Magasin.find(:first)].size
  end

  def test_on_size_find_with_with_offset
    (1..5).each {|i| create_person(i.to_s)}
    assert_equal 5,Person.find(:all,:limit => 5,:offset => 0).size
    assert_equal 3,Person.find(:all,:limit => 3,:offset => 1).size
    assert_equal 1,Person.find(:all,:limit => 1,:offset => 3).size
  end

  def test_on_values_with_find_with_offset
    
    (1..5).each {|i| create_person(i.to_s)}
    people = Person.find(:all,:limit => 2,:offset => 2)
   
  end
end
