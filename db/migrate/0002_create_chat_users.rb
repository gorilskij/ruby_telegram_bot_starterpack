class CreateChatUsers < ActiveRecord::Migration[6.1]
  def change
    name = "chat_users"
    execute(<<-SQL
      CREATE SEQUENCE IF NOT EXISTS #{name}_id_seq;
      CREATE TABLE IF NOT EXISTS #{name} (
        id          integer PRIMARY KEY DEFAULT nextval('#{name}_id_seq'),
        name        varchar(80),
        tg_user_id  varchar(80),
        tg_chat_id  varchar(80) references chats(tg_chat_id),
        pidor_count integer DEFAULT 0,
        UNIQUE (tg_chat_id, tg_user_id)
      );
    SQL
  )
  end
end
