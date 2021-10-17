require 'active_record'

class DBConfigurator
  ATTRIBUTES = %i( db_url ).freeze
  include Configurable.with(*ATTRIBUTES)

  def self.configure(*args)
    puts 'Configuring db...'
    super *args
    connection_details = config.db_url
    connection = ActiveRecord::Base.establish_connection(connection_details)
    puts 'Finished'
  end
end