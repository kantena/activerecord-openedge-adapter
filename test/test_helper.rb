require 'rubygems'
require 'active_record'
['models/types','models/pet','models/person','models/office'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end


database_config = File.join(File.dirname(__FILE__),'db/database.yml')
ActiveRecord::Base.establish_connection(YAML::load(File.open(database_config)))


def create_office 
  Office.create(:codsoc =>'ER',:codtab =>'VER10')
end
 
def create_person (name)
  Person.create(:name => name)
end

def create_pet (name)
  pet =  Pet.new()
  pet.name = name
  pet.badge = "A001"
  pet.save
  pet
end


def create_type
  Types.new.save
  Types.find :first
end


def column(klass,name)
  klass.columns.each {|col| return col if col.name == name}
end