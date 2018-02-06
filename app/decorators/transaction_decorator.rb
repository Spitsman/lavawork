class TransactionDecorator < BaseDecorator

  delegate_all

  decorates_association :sender
  decorates_association :receiver

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

  def display_commission
    h.number_to_currency(self.commission&.round(2), unit: 'lv')
  end

  def display_amount
    h.number_to_currency(self.amount&.round(2), unit: 'lv')
  end

end
