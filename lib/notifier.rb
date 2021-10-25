require 'pry'

class Notifier

  delegate :chat_id, :last_scanned, :users,
    :users_present?, :user_id, :username,
    :bot, :time_passed, :mention,
    to: :caller

  attr_reader :caller

  ALREADY_SETUP = "Я уже настроен".freeze
  STARTED = [
    "Работаем",
    "Введите / чтобы увидеть все команды"
  ].freeze
  SCAN = [
    "Зачем будить?",
    "Вы думаете это все на облаке крутиться?!",
    "Вообще-то, в вашем канале сидит маленький китаец и бросает кости. Постыдитесь.",
    "Ты пидор, %s!"
  ]
  SCAN_ALREADY_DONE = [
    "Китаец просыпается...",
    "Сверяет данные...",
    "Сегодня уже проводился розыгрыш, спешить некуда! %s все еще пидорасина. Китаец продолжает спать."
  ]
  TIME_LEFT = "Времени осталось: %s часов и %s минут"
  NOBODY_TO_SCAN = "Никто не зарегестрировался, так что пидорасы все!".freeze
  LAST_SCAN = [
    "Секунду, сверяю данные",
    "Последний пидор %s"
  ]
  NO_LAST_SCAN = "Никто))0)".freeze
  RESULTS = "Не спится, животные...".freeze
  REGISTER = [
    "Сек, открою ексель файл",
    "Тебя зарегестрировано, %s"
  ]
  ALREADY_REGISTERED = "Ты уже зарегистрирован, %s!"
  NOT_STARTED = "Нужно написать /start сначала".freeze
  NOT_REGISTERED = "Нет пидоров!".freeze
  LAST_PIDORS = "Последние пидоры:".freeze
  YOLOXD = [
    "Сука, угадал",
    "Твои очки анулированы, гений."
  ]
  REMINDER = [
    "Внимание!",
    "Меня просили автоматически не сканировать на пидора в этой группе...",
    "По-этому я просто напоминаю, что уже есть такая возможность!"
  ]
  CONFIRM_SUBSCRIPTION = [
    "Супер, еще работа",
    "Нет чтобы самим следить за временем. Ленивые засранцы",
    "Ладно, напомню следующий раз когда придет время сканировать"
  ]
  ALREADY_SUBSCRIBED = "Вы уже подписаны на напоминание!"
  NO_SUBSCRIPTION = "Вы не подписаны на напоминание!"
  CONFIRM_UNSUBSCRIPTION = "Спасибо за отписку, неблагодарные"

  def initialize(caller:, sleep: 1)
    @caller = caller
    @sleep = sleep
  end

  def notify_confirm_unsubscription
    notify(text: CONFIRM_UNSUBSCRIPTION)
  end

  def notify_no_subscription
    notify(text: NO_SUBSCRIPTION)
  end

  def notify_confirm_subscription
    notify(text: CONFIRM_SUBSCRIPTION)
  end

  def notify_already_subscribed
    notify(text: ALREADY_SUBSCRIBED)
  end

  def notify_reminder(chat_ids)
    chat_ids.each do |c_id|
      notify(text: REMINDER, c_id: c_id)
    end
  end

  def notify_reset
    notify(text: YOLOXD)
  end

  def notify_already_setup
    notify(text: ALREADY_SETUP)
  end

  def notify_started
    notify(text: STARTED)
  end

  def notify_scan
    return unless last_scanned
    notify(text: SCAN, mode: 'Markdown', string_arg: mention(last_scanned["tg_user_id"], last_scanned["name"]))
  end

  def notify_scan_already_done
    return unless last_scanned
    notify(text: SCAN_ALREADY_DONE, string_arg: last_scanned["name"])
    notify_time_left
  end

  def notify_time_left
    notify(text: TIME_LEFT, string_arg: [(24 - time_passed/1.hour).to_i, (60 - (time_passed/1.minute) % 60).to_i])
  end

  def notify_nobody_to_scan
    notify(text: NOBODY_TO_SCAN)
  end

  def notify_last_scan
    return unless last_scanned
    notify(text: LAST_SCAN, string_arg: last_scanned["name"])
  end

  def notify_no_last_scan
    notify(text: NO_LAST_SCAN)
  end 

  def notify_results
    notify(text: RESULTS)
    notify(text: statistics_text, mode: 'HTML')
  end

  def notify_register
    notify(text: REGISTER, mode: 'Markdown', string_arg: mention(user_id, username))
  end

  def notify_already_registered
    notify(text: ALREADY_REGISTERED, mode: 'Markdown', string_arg: mention(user_id, username))
  end

  def notify_not_started
    notify(text: NOT_STARTED)
  end

  def notify(text:, mode: nil, string_arg: nil, c_id: chat_id)
    if text.respond_to?(:each)
      text.each do |message|
        notify_user(text: message, mode: mode, string_arg: string_arg, chat_id: c_id)
        sleep(@sleep)
      end
    else
      notify_user(text: text, mode: mode, string_arg: string_arg, chat_id: c_id)
    end
  end

  private

  def statistics_text
    return NOT_REGISTERED unless users_present?

    text = "<pre>#{LAST_PIDORS}\n\n"
    @store = users

    longest_row = @store.map { |s| s["name"] }.map(&:size).max + 7  
    @store.each do |entry|
      text << format_row(longest_row, entry["name"], entry["pidor_count"])
    end
    "#{text}</pre>"
  end

  def format_row(longest, k, v)
    "#{k}#{' ' * ((longest - k.size))}#{v}\n"
  end

  def notify_user(text:, mode: nil, string_arg: nil, chat_id:)
    unless bot.api.get_chat(chat_id: chat_id)['result']['permissions']['can_send_messages']
      Chat.find_by(tg_chat_id: chat_id).destroy!
      return
    end
    bot.api.send_message(chat_id: chat_id, text: format(text, *string_arg), parse_mode: mode)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    error_data = e.instance_variable_get("@data")
    if error_data && error_data["description"] == "Forbidden: the group chat was deleted"
      Chat.find_by(tg_chat_id: chat_id).destroy!
    end
  end
end
