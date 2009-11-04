require 'test/unit'
require 'test_helper'

class FindersTest < Test::Unit::TestCase

  def setup
    Person.delete_all
    (1..5).each {|i| create_person(i.to_s)}
  end
  
  def test_find_all_with_limit
    (1..5).each {|i| create_person(i.to_s)}
    assert_equal 2,Person.find(:all,:limit => 2).size
    assert_equal 1,Person.find(:all,:limit => 1).size
    assert_equal Person.count,Person.find(:all,:limit => Person.count + 10).size
  end

  def test_find_first
    assert_equal 1,[Person.find(:first)].size
  end

  def test_on_size_find_with_with_offset
    (1..5).each {|i| create_person(i.to_s)}
    assert_equal 5,Person.find(:all,:limit => 5,:offset => 0).size
    assert_equal 3,Person.find(:all,:limit => 3,:offset => 1).size
    assert_equal 1,Person.find(:all,:limit => 1,:offset => 3).size
  end

end
