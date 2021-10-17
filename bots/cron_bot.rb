require 'telegram/bot'
require 'pry'
require 'active_record'
require 'active_support/all'
Dir["#{Dir.pwd}/models/**/*.rb"].each { |file| require file }

require_relative '../lib/notifier'
require_relative '../lib/telegram_bot'
require_relative '../lib/configuration'

class CronBot
  attr_accessor :bot, :notifier

  delegate :notify_reminder, to: :notifier

  def initialize
    @notifier = Notifier.new(caller: self)
  end

  def call
    TelegramBot.run do |bot|
      @bot = bot
      notify_reminder(subscribed_to_reminder_chat_ids)
    end
  end

  def self.call
    new.call
  end

  private

  def subscribed_to_reminder_chat_ids
    Chat
      .joins(:subscriptions)
      .where(subscriptions: { name: "Reminder" })
      .distinct
      .map(&:tg_chat_id)
  end
end