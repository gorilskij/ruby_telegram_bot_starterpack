class Chat < ActiveRecord::Base
  has_many :users, class_name: 'ChatUser'
  has_many :subscriptions
end