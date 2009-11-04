class CreateOffices < ActiveRecord::Migration
  def self.up
    create_table :offices, :id => false,:force =>true do |t|
      t.string :codsoc
      t.string :codtab
      t.string :name
    end
  end

  def self.down
    drop_table :offices
  end
end