class ChatsController < BotsController
  def index
  end

  def show
  end

  def create
    return notify(@chat.tg_chat_id, t('already_setup')) if chat_exists?

    create_chat
    notify(@chat.tg_chat_id, t('started')) if chat_exists?
  end

  def destroy
  end

  def update
  end

  private

  def chat_exists?
    load_chat
    !!@chat
  end

  def create_chat
    Chat.create! create_chat_params
  end

  def load_chat
    @chat ||= Chat.find_by chat_params
  end

  def load_chats
    @chats ||= Chat.all
  end

  def chat_params
    params.permit(:tg_chat_id)
  end

  def create_chat_params
    params.permit(:tg_chat_id, :last_scanned_time)
  end

  def update_chat_params
  end
end