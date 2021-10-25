class Chat < ActiveRecord::Base
end

class AddLocaleToChats < ActiveRecord::Migration[6.1]
  def change
    add_column :chats, :locale, :string, default: 'ru'

    Chat.update_all(locale: 'ru')

    change_column_null :chats, :locale, false
  end
end