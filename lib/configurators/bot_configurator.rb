require_relative '../../concerns/configurable'

class BotConfigurator
  ATTRIBUTES = %i( token ).freeze
  include Configurable.with(*ATTRIBUTES)


  def self.configure(*args)
    puts 'Configuring bot...'
    super *args
    puts 'Finished'
  end
end