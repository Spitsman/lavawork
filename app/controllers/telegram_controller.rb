class TelegramController < BaseController

  helper_method :users_collection

  def index
  end

  def broadcast
  end

  def send_broadcast
    res = User.all.map do |user|
      bot.send_message(text: message_params[:text], chat_id: user.telegram_id)
    end

    if res.all?{|r| r['ok']}
      flash[:success] = 'Cообщения отправлены'
    else
      flash[:error] = 'Что-то пошло не так'
    end

    redirect_to broadcast_path
  end

  def send_message
    res = bot.send_message(text: message_params[:text], chat_id: message_params[:chat_id])

    if res['ok']
      flash[:success] = 'Сообщение отправлено'
    else
      flash[:error] = "#{JSON.parse(res.body)['error_code']} #{JSON.parse(res.body)['description']}"
    end

    redirect_to messages_path
  end

  protected

  def bot
    @bot ||= Telegram.bot
  end

  def send_message_service
    @send_message_service ||= Telegram::SendMessageService.new
  end

  def message_params
    params.fetch(:message, {})
  end

  def users_collection
    @users_collection ||= User.all.map{|u|[u.decorate.display_name, u.telegram_id]}
  end

end
