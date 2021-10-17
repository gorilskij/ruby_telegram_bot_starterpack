require_relative '../../models/chat_user'
require_relative '../../models/chat'

class ChangeUserForeignKey < ActiveRecord::Migration[6.1]
  def change
    add_column :chat_users, :chat_id, :integer

    ChatUser.all.each do |user|
      user.update! chat_id: Chat.find_by(tg_chat_id: user.tg_chat_id).id
    end

    add_foreign_key :chat_users, :chats
    remove_column :chat_users, :tg_chat_id
  end
end