require_relative '../../concerns/configurable'
require_relative 'bot_configurator'
require_relative 'i18n_configurator'
require_relative 'db_configurator'

class AppConfigurator
  ATTRIBUTES = %i( token db_url pashalka i18n_load_path i18n_locale i18n_available_locales ).freeze
  include Configurable.with(*ATTRIBUTES)

  def self.configure(force = true, *args)
    super
    @force = force
    configure_i18n
    configure_db
    configure_bot
  end

  def self.configure_db
    DBConfigurator.configure(@force) do |configuration|
      configuration.db_url = config.db_url
    end
  end

  def self.configure_i18n
    I18nConfigurator.configure(@force) do |configuration|
      configuration.load_path = config.i18n_load_path
      configuration.locale = config.i18n_locale
      configuration.available_locales = config.i18n_available_locales
    end
  end

  def self.configure_bot
    BotConfigurator.configure(@force) do |configuration|
      configuration.token = config.token
    end
  end
end
