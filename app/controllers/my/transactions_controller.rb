class My::TransactionsController < My::BaseController

  def create
    # byebug
    result = TransferLaveService.new(current_user, User.find(params[:receiver]), params[:amount]).call
    if result.first
      render json: { success: true, transaction: result.third}
    else
      render json: { success: false, message: result.second }, status: 400
    end
  end

end
