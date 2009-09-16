require 'rubygems'
require 'active_record'

class Office < ActiveRecord::Base

  @spec = {:adapter  => "openedge",
    :port => 20001,
    :username => "pca",
    :password => "",
    :host     => "127.0.0.1",
    :database => "appros"}
  establish_connection(@spec)

  validates_presence_of :external_id
  validates_uniqueness_of :external_id

end
