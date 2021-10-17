require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'active_record'
require 'yaml'

connection_details = begin
  YAML::load(IO.read('config/database.yml'))["database_url"]
rescue Errno::ENOENT
  ENV["DATABASE_URL"]
end

namespace :db do
  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Tasks::DatabaseTasks.migrate
  end

  # Both require hash like db configuration,
  # but string url is used
  #
  # desc 'Create the database'
  # task :create do
  #   admin_connection = connection_details.merge({
  #     'database'=> 'postgres',
  #     'schema_search_path'=> 'public'
  #   })
  #   ActiveRecord::Base.establish_connection(admin_connection)
  #   ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  # end
  #
  # desc 'Drop the database'
  # task :drop do
  #   connection_details = YAML::load(File.open('config/database.yml'))
  #   admin_connection = connection_details.merge({
  #     'database'=> 'postgres',
  #     'schema_search_path'=> 'public'
  #   })
  #   ActiveRecord::Base.establish_connection(admin_connection)
  #   ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  # end
end
