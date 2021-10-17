class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    name = "subscriptions"
    execute(<<-SQL
      CREATE SEQUENCE IF NOT EXISTS #{name}_id_seq;
      CREATE TABLE IF NOT EXISTS #{name} (
        id         integer PRIMARY KEY DEFAULT nextval('#{name}_id_seq'),
        tg_chat_id varchar(80) references chats(tg_chat_id),
        name       varchar(80),
        UNIQUE (tg_chat_id, name)
      );
    SQL
    )
  end
end