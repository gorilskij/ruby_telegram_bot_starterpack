require 'active_support/all'

require_relative '../lib/configurators/app_configurator'
require_relative '../concerns/configurable'
Dir["#{Dir.pwd}/models/**/*.rb"].each { |file| require file }

AppConfigurator.configure do |config|
  # Configure bot
  config.token = begin
    YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']
  rescue Errno::ENOENT
    ENV["TOKEN"]
  end

  # Configure database
  config.db_url = begin
    YAML::load(IO.read('config/database.yml'))["database_url"]
  rescue Errno::ENOENT
    ENV["DATABASE_URL"]
  end

  # Configure pashalka
  config.pashalka = begin
    YAML::load(IO.read('config/pashalka.yml'))["pashalka"]
  rescue Errno::ENOENT
    ENV["PASHALKA"]
  end

  # Configure i18n
  config.i18n_locale = :ru
  config.i18n_load_path = Dir['config/locales.yml']
  config.i18n_available_locales = [:ru]
end
