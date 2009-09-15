require 'rubygems'
require 'active_record'

class Person < ActiveRecord::Base

 
   @spec = {:adapter  => "jdbcmysql",
    :port => 3306,
    :username => "root",
    :password => "",
    :host     => "127.0.0.1",
    :database => "foo"}
  establish_connection(@spec)
end
