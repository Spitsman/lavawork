class TelegramController < ApplicationController

  def message
    Telegram::SendMessageService.new.call(text: 'asdf', chat_id: '3002462')
    render json: { params: params }
  end

end
