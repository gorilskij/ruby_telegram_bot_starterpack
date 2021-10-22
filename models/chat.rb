class Chat < ActiveRecord::Base
  has_many :users, class_name: 'ChatUser', dependent: :destroy
  has_many :subscriptions, dependent: :destroy
end
