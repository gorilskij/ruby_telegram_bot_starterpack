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
            BotNotifier.config.bot.api.send_message(chat_id: tg_chat_id, text: message, parse_mode: mode)
          end
        else
          BotNotifier.config.bot.api.send_message(chat_id: tg_chat_id, text: text, parse_mode: mode)
        end
      end

      BotsController.define_method :mention do |id, name|
        "[#{name}](tg://user?id=#{id})"
      end
    end
  end
end