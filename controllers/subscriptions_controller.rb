class SubscriptionsController < BotsController  
  def create
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat
    
    load_subscription
    return notify(@chat.tg_chat_id, t("already_subscribed")) if subscription_exists?

    create_subscription
    return notify(@chat.tg_chat_id, t("confirm_subscription")) if subscription_exists?
  end

  def destroy
    load_chat
    return notify(params[:tg_chat_id], t('not_started')) unless !!@chat

    load_subscription
    return notify(@chat.tg_chat_id, t("no_subscription")) unless subscription_exists?

    destroy_subscription
    return notify(@chat.tg_chat_id, t("confirm_unsubscription")) unless subscription_exists?
  end

  private
  
  def subscription_exists?
    @chat.subscriptions.exists?(subscription_params)
  end

  def load_chat
    @chat ||= Chat.find_by(chat_params)
  end

  def load_subscription
    @subscription ||= @chat.subscriptions.find_by(subscription_params)
  end

  def create_subscription
    @chat.subscriptions.create(subscription_params)
  end

  def destroy_subscription
    @subscription.destroy!
  end

  def subscription_params
    params.permit(:name)
  end

  def chat_params
    params.permit(:tg_chat_id)
  end
end
