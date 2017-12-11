class MessageDecorator < BaseDecorator

  delegate_all

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

end
