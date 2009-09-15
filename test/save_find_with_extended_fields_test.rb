require 'test/unit'

['test_helper','models/person','models/pet'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end

class SaveFindTest < Test::Unit::TestCase

  def setup
    Person.delete_all
  end
  def test_extended_attributes_should_be_accessed_as_array
    p = Person.new()
    assert p.adress[1]= '9'
  end

  def test_save_extended_attr_and_retrieve_it_as_array_with_default_value
    p = Person.new()
    p.adress[1]=''
    assert p.save
    p = Person.find :first
    #p.reload
    assert_equal '', p.adress[1]
  end

  def test_save_extended_attr_and_retrieve_it_as_array
    p = Person.new()
    adress = [nil,'2','Rue de la roquette','75011','Paris','France','','','']
    p.adress = adress
    assert p.save
    #p.reload
    p = Person.find :first
    assert_equal adress, p.adress
  end

  def test_update_with_extended_attr
    albert = create_person("Albert")
    albert.adress[1] = "2 rue de la roquette"
    assert albert.save
    assert_equal "2 rue de la roquette",albert.adress[1]
  end

  def test_find_first_with_no_result
    assert Person.find(:first).nil?
  end

  def test_find_all_with_extended_columns
    assert Person.find(:all).empty?
  end

end
