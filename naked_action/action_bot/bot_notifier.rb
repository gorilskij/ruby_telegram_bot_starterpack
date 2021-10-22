require_relative '../../controllers/bots_controller'

module ActionBot
  class BotNotifier
    include Configurable.with(:bot)

    def self.configure(force = true, *args)
      super(force, *args)

      BotsController.define_method :notify do |tg_chat_id, text, mode = nil|
        if text.respond_to?(:each)
          text.each do |message|
            sleep(0.5)
            BotNotifier.notify_chat(tg_chat_id, message, mode)
          end
        else
          BotNotifier.notify_chat(tg_chat_id, text, mode)
        end
      end

      BotsController.define_method :mention do |id, name|
        "[#{name}](tg://user?id=#{id})"
      end
    end

    def notify_chat(chat_id, text, mode)
      BotNotifier.config.bot.api.send_message(chat_id: chat_id, text: text, parse_mode: mode)
    rescue Telegram::Bot::Exceptions::ResponseError => e
      if e.instance_variable_get("@data")["description"] == "Forbidden: the group chat was deleted"
        Chat.find_by(tg_chat_id: chat_id).destroy!
      end
    end
  end
end
