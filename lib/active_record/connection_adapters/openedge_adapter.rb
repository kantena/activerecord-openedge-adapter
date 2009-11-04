jar_files = ['util.jar', 'base.jar', 'openedge.jar']
begin
  jar_files.each do |jarfile|
    require jarfile
  end
rescue LoadError
  puts "These Progress jar files are required in lib :['util.jar', 'base.jar', 'openedge.jar']"
end



require 'jdbc_adapter'

['../../jdbc_adapter/jdbc_openedge','connection_adapter'].each do |req_file|
  require File.join(File.dirname(__FILE__),req_file )
end
