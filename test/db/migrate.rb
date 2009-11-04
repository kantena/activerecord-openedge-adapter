namespace :db do
  namespace :test do
    desc 'Migrate database for tests units. Run with parameter -I"lib" '
    task :migrate do
      load_migration_files
      database_config = YAML::load(File.open(File.join(File.dirname(__FILE__),"database.yml")))
      ActiveRecord::Base.establish_connection(database_config)
      CreatePeople.up
      CreateTypes.up
      CreatePets.up
      CreateOffices.up
    end
  end
end


private

def load_migration_files
  ['create_people','create_pets','create_types','create_offices'].each do |migration_file|
    require File.join(File.dirname(__FILE__),migration_file)
  end
end



