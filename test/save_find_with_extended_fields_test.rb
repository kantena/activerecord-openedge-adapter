require 'test/unit'
require 'test_helper'

class SaveFindTest < Test::Unit::TestCase

  def setup
    Person.delete_all
  end
  
  def test_extended_attributes_should_be_accessed_as_array
    assert Person.new().address[1].nil?
  end
 
  def test_create_extended_attr_and_retrieve_it_as_array
    p = Person.new()
    address = [nil,'2','Rue de la roquette','75011','Paris','France','','','']
    p.address = address
    assert p.save
    assert_equal address, p.reload.address
    assert_equal 'Rue de la roquette', p.address[2]
  end

  def test_update_with_extended_attr
    albert = create_person("Albert")
    albert.address[1] = "2 rue de la roquette"
    assert albert.save
    assert_equal "2 rue de la roquette",albert.address[1]
  end

end
