class ChatUsersController < BotsController
  # before_action -> { return }, only: %i[show]
  # before_action :load_chat

  def index
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat

    load_chat_users
    return notify(@chat.tg_chat_id, t('not_registered')) unless @chat_users.count.positive?
    
    notify(@chat.tg_chat_id, statistics_text, 'HTML')
  end

  def show; end

  def create
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat

    load_chat_user
    return notify(@chat.tg_chat_id, t('already_registered', param: mention(params[:tg_user_id], params[:name])), 'Markdown') if !!@chat_user

    create_user
    notify(@chat.tg_chat_id, t('register', param: mention(params[:tg_user_id], params[:name])), 'Markdown')
  end

  def scan
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat

    load_chat_users
    return notify(@chat.tg_chat_id, t('no_last_scan')) unless @chat_users.count.positive?

    unless time_has_passed?
      return unless last_scanned
      notify(
        @chat.tg_chat_id,
        t('scan_already_done', param: last_scanned["name"])
      )
      notify(
        @chat.tg_chat_id,
        t(
          'time_left',
          hours: (24 - time_passed/1.hour).to_i,
          minutes: (60 - (time_passed/1.minute) % 60).to_i
        )
      )
      return
    end

    user = @chat.users.order("random()").first

    @chat.update!(last_scanned_time_params.merge(last_scanned_user_id: user.id))
    user.increment_pidor_count
    notify(
      @chat.tg_chat_id,
      t('scan', param: mention(last_scanned["tg_user_id"], last_scanned["name"])),
      'Markdown'
    )
  end

  def reset
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat

    load_chat_user
    @chat_user.reset_pidor_count
    notify(@chat.tg_chat_id, t('yoloxd'))
  end

  def last
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat
    return notify(@chat.tg_chat_id, t('no_last_scan')) unless last_scanned
    return notify(@chat.tg_chat_id, t('last_scan', param: last_scanned["name"]))
  end

  private

  def load_chat
    @chat ||= Chat.find_by chat_params
  end

  def chat_params
    params.permit(:tg_chat_id)
  end

  def chat_user_params
    params.permit(:tg_user_id)
  end

  def load_chat_user
    @chat_user ||= @chat.users.find_by chat_user_params
  end

  def load_chat_users
    @chat_users ||= @chat.users
  end

  def last_scanned_time_params
    { last_scanned_time: Time.now.in_time_zone('Europe/Kiev').beginning_of_day }
  end

  def create_chat_user_params
    params.permit(:tg_user_id, :name)
  end

  def update_chat_user_params
  end

  def create_user
    @chat.users.create create_chat_user_params
  end

  def last_scanned
    return unless @chat
    return unless @chat.last_scanned_user_id
    
    @last_scanned ||= ChatUser.find(@chat.last_scanned_user_id).attributes.slice("tg_user_id", "name")
  end

  def time_has_passed?
    (time_passed/1.day).abs >= 1
  end

  def time_passed
    Time.now - @chat.last_scanned_time
  end

  def statistics_text
    notify(@chat.tg_chat_id, t('results'))

    text = "<pre>#{t('last_pidors')}\n\n"

    ordered_chat_users = @chat_users.order(pidor_count: :desc, updated_at: :desc)
    longest_row = ordered_chat_users.map { |user| user.name }.map(&:size).max + 7  
    ordered_chat_users.each do |user|
      text << "#{user.name}#{' ' * ((longest_row - user.name.size))}#{user.pidor_count}\n"
    end
    "#{text}</pre>"
  end
end