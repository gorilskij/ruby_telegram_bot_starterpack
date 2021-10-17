require_relative 'configurators/bot_configurator'

class TelegramBot < Telegram::Bot::Client
  def self.run(*_, &block)
    super(BotConfigurator.config.token, &block)
  end
end