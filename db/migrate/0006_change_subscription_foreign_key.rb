require_relative '../../models/subscription'
require_relative '../../models/chat'

class ChangeSubscriptionForeignKey < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :chat_id, :integer

    Subscription.all.each do |subscription|
      subscription.update! chat_id: Chat.find_by(tg_chat_id: subscription.tg_chat_id).id
    end

    add_foreign_key :subscriptions, :chats
    remove_column :subscriptions, :tg_chat_id
  end
end