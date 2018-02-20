class ResidentDecorator < BaseDecorator

  delegate_all

  decorates_association :sent_transactions
  decorates_association :received_transactions

  def display_name
    [source.first_name&.titleize, source.last_name&.titleize].join(' ').strip
  end

  def display_name_with_telegram_username
    "#{source.first_name.titleize} #{source.last_name&.titleize} (#{source.telegram_username})"
  end

  def display_active
    source.active? ? '✓' : display_empty_space
  end

  def display_expire_at
    Russian::strftime(source.expire_at, "%d %B %Y")
  end

  def display_amount_changed_at
    return display_empty_space if source.amount_changed_at.nil?
    Russian::strftime(source.amount_changed_at, "%d %B %Y")
  end

  def display_amount
    h.number_to_currency(self.amount&.round(2), unit: 'lv')
  end

  def display_current_amount
    h.number_to_currency(self.current_amount&.round(2), unit: 'lv')
  end

  def demurrage_info
    return "Нулевой баланс" if source.amount.nil? || source.amount_changed_at.nil?
    "Демередж вычитается из #{display_amount} начиная с #{display_amount_changed_at}"
  end

  def likers_list
    source.likers(source.class).map do |liker|
      liker.decorate.display_name
    end.join('<br>')
  end

end
