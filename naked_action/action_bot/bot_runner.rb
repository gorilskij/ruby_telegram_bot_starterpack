require_relative '../../lib/configurators/bot_configurator'
require 'pry'

class BotRunner < Telegram::Bot::Client
  def self.run(*_, &block)
    super(BotConfigurator.config.token, &block)
  end
end