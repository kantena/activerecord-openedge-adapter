class CreatePets < ActiveRecord::Migration
  def self.up
    create_table :pets, :force => true do |t|
      t.string :badge
      t.string :name
    end
    execute ("alter table pub.pets add awards integer VARARRAY[10] default 0")
  end
end

def self.down
  drop_table(:pets)
end
