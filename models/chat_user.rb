class ChatUser < ActiveRecord::Base
  belongs_to :chat

  def reset_pidor_count
    update! pidor_count: 0
  end

  def increment_pidor_count
    update! pidor_count: pidor_count + 1
  end
end