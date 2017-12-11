class MessagesController < ApplicationController

  helper_method :messages_collection

  def index
  end

  protected

  def messages_collection
    @messages_collection ||= Message.page(params[:page]).decorate
  end

end
