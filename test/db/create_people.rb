class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people, :force =>true do |t|
      t.string :name
      t.string :codsoc
      t.string :codtab
    end
    execute ("alter table pub.people add address varchar(20) VARARRAY[8]")
  end

  def self.down
    drop_table :people
  end
end