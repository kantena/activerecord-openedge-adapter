require 'rake'
require 'active_record'
#require (File.join(File.dirname(__FILE__),'lib/active_record/connection_adapters/openedge_adapter'))


class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force =>true do |t|
      t.name :string
    end
  end

  def self.down
    drop_table :users
  end
end


desc "Migrate database for tests units. Run with parameter -I'lib' "
task :tests_migrate do
  @spec = {:adapter  => "openedge",
    :port => 22100,
    :username => "pca",
    :password => "",
    :host     => "127.0.0.1",
    :database => "hermes_test"}
  ActiveRecord::Base.establish_connection(@spec)
     
  CreateUsers.up
  CreateUsers.down
end



