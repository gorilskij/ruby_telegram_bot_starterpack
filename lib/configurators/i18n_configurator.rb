class I18nConfigurator
  ATTRIBUTES = %i( load_path locale available_locales ).freeze
  include Configurable.with(*ATTRIBUTES)

  def self.configure(*args)
    puts 'Configuring i18n...'
    super *args
    puts 'Finished'
    ATTRIBUTES.each do |attr|
      I18n.public_send("#{attr}=", config.public_send("#{attr}"))
    end
  end
end