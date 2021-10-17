require 'pry'
require 'action_controller'

require_relative '../../controllers/bots_controller'
require_relative 'bot_runner'
Dir["#{Dir.pwd}/controllers/**/*.rb"].each { |file| require file }

module ActionBot
  class Base
    def self.inherited(klass)
      models = Dir["#{Dir.pwd}/models/**/*.rb"].map { |f| f.split('/').last.split('.').first.pluralize.camelize }
      models.each do |model_name|
        controller = "#{model_name}Controller".constantize
        methods = controller.instance_methods(false)

        methods.each do |method|
          define_method "#{model_name.underscore}_#{method}_action" do |params = {}|
            controller_instance = controller.new
            controller_instance.params = ActionController::Parameters.new params
            controller_instance.public_send(method)
          end
        end

        # this won't work. Need to define a class instance/class var to hold the callbacks for each action
        # controller.define_singleton_method :before_action do |function, only: methods|
        #   binding.pry
        #   methods.each do |method|
        #     new_method_name = "original_#{method}".to_sym
        #     alias_method new_method_name, method
    
        #     define_method m do
        #       if function.respond_to?(:call)
        #         function.call
        #       elsif controller.instance_methods(false).include?(function)
        #         controller.send(function)
        #       end
        #       send(new_method_name)
        #     end
        #   end
        # end
      end
    end

    def on(condition, **kwargs)
      return unless condition

      params = kwargs.delete(:params)
      controller, action = kwargs.first
      method_name = "#{controller}_#{action}_action"
      raise "No such method: #{method_name}" unless respond_to?(method_name)
      public_send(method_name, params)
      throw(:done)
    end

    def bot_runner
      BotRunner
    end
  end
end
