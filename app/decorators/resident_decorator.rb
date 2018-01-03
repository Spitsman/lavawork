class ResidentDecorator < BaseDecorator

  delegate_all

  decorates_association :sent_transactions
  decorates_association :received_transactions

  def display_name
    [source.first_name.titleize, source.last_name.titleize].join(' ')
  end

  def display_name_with_telegram_username
    "#{source.first_name.titleize} #{source.last_name.titleize} (#{source.telegram_username})"
  end

  def display_active
    source.active? ? '✓' : display_empty_space
  end

  def display_expire_at
    Russian::strftime(source.expire_at, "%d %B %Y")
  end

end
