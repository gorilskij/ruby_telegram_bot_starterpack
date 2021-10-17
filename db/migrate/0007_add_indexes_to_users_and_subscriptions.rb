class AddIndexesToUsersAndSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_index :chat_users, %i[chat_id tg_user_id], unique: true
    add_index :subscriptions, %i[chat_id name], unique: true
  end
end