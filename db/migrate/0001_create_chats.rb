class CreateChats < ActiveRecord::Migration[6.1]
  def change
    name = "chats"
    execute(<<-SQL
      CREATE SEQUENCE IF NOT EXISTS #{name}_id_seq;
      CREATE TABLE IF NOT EXISTS #{name} (
        id                   integer PRIMARY KEY DEFAULT nextval('#{name}_id_seq'),
        tg_chat_id           varchar(80) UNIQUE,
        last_scanned_time    timestamp NOT NULL DEFAULT NOW() - INTERVAL '2 DAY',
        last_scanned_user_id integer
      );
    SQL
    )
  end
end