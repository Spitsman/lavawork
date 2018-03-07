class My::TransactionsController < My::BaseController

  def create
    result = TransferLaveService.new(current_user, User.find(params[:receiver]), params[:amount]).call
    if result.first
      render json: { success: true, transaction: {receiver: result.third.receiver.decorate.display_name, amount: result.third.amount, commission: result.third.commission, created_at: result.third.decorate.display_created_at}}
    else
      render json: { success: false, message: result.second }, status: 400
    end
  end

end
