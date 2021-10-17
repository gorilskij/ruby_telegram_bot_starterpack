class AddUpdatedAtToChatUsers < ActiveRecord::Migration[6.1]
  def change
    execute(<<-SQL
      ALTER TABLE chat_users
      ADD COLUMN IF NOT EXISTS updated_at timestamp NOT NULL DEFAULT NOW();
    SQL
    )
  end
end