class SettingsController < BotsController
  def change_locale
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat

    available_locales = %w[en ru]
    return notify(params[:tg_chat_id], t('no_such_locale', param: available_locales.join(', '))) unless available_locales.include?(params[:locale])

    @chat.update! locale: params[:locale]

    notify(params[:tg_chat_id], t('locale_changed', param: params[:locale]))
  end

  private

  def load_chat
    @chat ||= Chat.find_by chat_params
  end

  def chat_params
    params.permit(:tg_chat_id)
  end
end
