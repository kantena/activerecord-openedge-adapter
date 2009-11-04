class CreateTypes < ActiveRecord::Migration
  def self.up
    create_table :types, :force => true do |t|
      t.date :date
      t.decimal :decimal, :default => 0
      t.boolean :logical, :default => false
      t.timestamp :datetime_tz
      t.datetime :datetime
      t.decimal :float
      t.string :char, :limit => 1
      t.string :chars, :limit => 8, :cs => true
      t.integer :integer
      t.string :raw
    end
    execute ("alter table pub.types add extend_chars varchar(8) VARARRAY[3] default ''")
    execute ("alter table pub.types add extend_numeric numeric(8) VARARRAY[3] default 0")
  end
end

def self.down
  drop_table(:types)
end
