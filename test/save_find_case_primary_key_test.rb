require 'test/unit'
require 'test_helper'

class SaveFindTest < Test::Unit::TestCase
  include ActiveRecord
  
  # Tests dans le cas d'un clé primaire composée déclarée avec set_primary_keys
  
  def test_sequence_insert_find_delete_with_composite_key
    create_office
    mag = Office.find(:first,:conditions =>["codsoc = ? and codtab = ?",'ER','VER10'])
    assert mag.delete
    mag = Office.find(:first,:conditions =>["codsoc = ? and codtab = ?",'ER','VER10'])
    assert mag.nil?
  end

  def test_update_with_composite_key
    mag = create_office
    mag.name = "La Poste"
    assert mag.save!
    # mag.reload : ne fonctionne pas -> bug composite_primary_keys ligne 63
    mag = Office.find(:first,:conditions =>["codsoc = ? and codtab = ?",'ER','VER10'])
    assert mag.delete
  end
  
  # Tests dans le cas d'une clé primaire non composée , déclarée avec set-primary_key

  def test_sequence_insert_find_delete_with_primary_key
    Pet.delete_all
    pet = create_pet("toutou")
    pets = Pet.find(:all,:conditions =>["badge = ?",'A001'])
    assert_equal 1, pets.size
    pet = pets[0]
    assert !pet.nil?
    assert_equal "toutou", pet.name
    assert pet.delete
    assert Pet.find(:first,:conditions =>["badge = ?",'A001']).nil?
  end

  def test_update_with_primary_key
    pet = create_pet("toutou")
    pet.name = "medor"
    assert pet.save
    assert pet.reload
    assert_equal "medor", pet.name
    assert_equal 1, Pet.find(:all).size
    assert pet.delete
  end
  
  # Tests dans le cas d'une clé primaire id integer généré par sequence
  
  def test_sequence_insert_find_delete_with_id
    p = Person.find(:first)
    p = create_person("toto") if p.nil?
    assert p.delete
    assert_raise(RecordNotFound){Person.find(p.id)}
  end

  def test_update_with_id
    p = create_person("Georges")
    p.name = 'Laurent'
    assert p.save
    p.reload
    assert_equal 'Laurent', p.name
    assert p.delete
  end

  
end
