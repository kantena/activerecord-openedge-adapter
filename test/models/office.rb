require 'composite_primary_keys'

class Office < ActiveRecord::Base
  set_primary_keys :codsoc,:codtab
end
