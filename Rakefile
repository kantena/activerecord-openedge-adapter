require 'rake'
require 'rake/testtask'
require 'active_record'

namespace :db do
  desc "Migrate database for tests units"
  task :tests_migrate do
    @spec = {:adapter  => "openedge",
      :port => 20001,
      :username => "pca",
      :password => "",
      :host     => "127.0.0.1",
      :database => "appros"}
    ActiveRecord::Base.establish_connection(@spec)
    
    ActiveRecord::Schema.define(:version => 1) do

      create_table "activite",  :force => true do |t|
        t.name :string
       
      end
    end
  end

end

