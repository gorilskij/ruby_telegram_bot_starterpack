require 'active_support/all'

module Configurable
  def self.with(*args)
    config_class = Class.new do
      attr_accessor *args
    end

    Module.new do
      extend ActiveSupport::Concern
      class_methods do
        define_method :configure do |force = true, &block|
          block.call config
          return unless force

          missing = []
          args.each do |arg|
            missing << arg if config.public_send(arg).nil?
          end
          return if missing.empty?

          raise "#{missing.join(", ")} #{missing.size > 1 ? 'are' : 'is'} missing from config"
        end
    
        define_method :config do
          @config ||= config_class.new
        end
      end
    end
  end
end