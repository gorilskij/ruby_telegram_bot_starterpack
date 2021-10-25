class BotsController
  attr_accessor :params
  def t(*args)
    I18n.locale = load_chat.locale
    I18n.t(*args)
  end
end
