require 'pry'

class BotsController
  attr_accessor :params
  def t(*args)
    I18n.t(*args)
  end
end