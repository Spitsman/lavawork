class ResidentFacade

  attr_accessor :resident

  def initialize(resident)
    @resident = resident
  end

  def collection
    @collection ||= User.residents.order(:id).decorate
  end

  def decorated
    @decorated ||= @resident.decorate
  end

  def sent_transactions_collection
    @sent_transactions_collection ||= @resident.sent_transactions.ordered.limit(20).decorate
  end

  def received_transactions_collection
    @received_transactions_collection ||= @resident.received_transactions.ordered.limit(20).decorate
  end

  def messages_collection
    @messages_collection ||= @resident.messages.ordered.limit(10).decorate
  end

end
