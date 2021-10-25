require 'telegram/bot'
require 'pry'
require 'active_support/all'

require_relative '../naked_action/action_bot'
require_relative '../lib/configuration'

class Bot < ActionBot::Base
  COMMANDS = %i[ start stat reg scan last subscribe unsubscribe ].freeze
  PASHALKA_COMMAND = AppConfigurator.config.pashalka

  COMMANDS.each do |command|
    define_method("message_#{command}?") do
      @message&.text =~ /\A\/#{command}(#{bot_name})?\z/
    end
  end

  def message_change_locale?
    @message&.text =~ /\A\/changeLocale(#{bot_name})? [A-Za-z]{2}\z/
  end

  def message_pashal?
    @message&.text =~ /\A\/#{PASHALKA_COMMAND}(#{bot_name})?\z/
  end

  def call
    bot_runner.run do |bot|
      ActionBot::BotNotifier.configure do |config|
        config.bot = bot
      end

      @bot = bot
      bot.listen do |message|
        @message = message
        run
      end
    end
  end

  def self.call
    new.call
  end

  def bot_name
    @bot_name ||= "@#{@bot.api.get_me["result"]["username"]}"
  end

  def username
    @message.from.username || @message.from.first_name || @message.from.last_name
  end

  def user_id
    @message.from.id
  end

  def tg_chat_id
    @message.chat.id
  end

  def run
    return unless message_legal?

    catch(:done) do
      on message_start?, chats: :create, params: {
        tg_chat_id: tg_chat_id,
        last_scanned_time: 1.day.ago
      }
  
      on message_scan?, chat_users: :scan, params: {
        tg_chat_id: tg_chat_id
      }

      on message_last?, chat_users: :last, params: {
        tg_chat_id: tg_chat_id
      }

      on message_stat?, chat_users: :index, params: {
        tg_chat_id: tg_chat_id
      }

      on message_reg?, chat_users: :create, params: {
        tg_chat_id: tg_chat_id,
        tg_user_id: user_id,
        name: username
      }

      on message_pashal?, chat_users: :reset, params: {
        tg_chat_id: tg_chat_id,
        tg_user_id: user_id
      }

      on message_subscribe?, subscriptions: :create, params: {
        tg_chat_id: tg_chat_id,
        name: "Reminder"
      }

      on message_unsubscribe?, subscriptions: :destroy, params: {
        tg_chat_id: tg_chat_id,
        name: "Reminder"
      }

      on message_change_locale?, settings: :change_locale, params: {
        tg_chat_id: tg_chat_id,
        locale: @message.text.split.last
      }
    end
  end

  def message_legal?
    @message.respond_to?(:text)
  end
end
