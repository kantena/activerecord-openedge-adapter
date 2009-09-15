require 'rubygems'
require 'active_record'
require 'composite_primary_keys'

class Magasin < ActiveRecord::Base
  set_table_name "magasi"
  set_primary_keys :codsoc,:codtab
  
  @spec = {:adapter  => "openedge",
    :port => 20001,
    :username => "pca",
    :password => "",
    :host     => "127.0.0.1",
    :database => "appros"}
  establish_connection(@spec)

 
end
