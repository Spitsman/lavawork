class TransactionsController < BaseController

  helper_method :transactions_collection

  def index
  end

  protected

  def transactions_collection
    @transactions_collection ||= Transaction.includes(:receiver).includes(:sender).ordered.page(params[:page]).decorate
  end

end
