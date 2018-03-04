module Bot::ResetPassword
  extend ActiveSupport::Concern

  def reset_password
    respond_with :message,
      text: 'Укажите новый пароль длиной не менее 8 символов'
    save_context :wait_for_new_password
  end

  included do
    context_handler :wait_for_new_password do |*words|
      session[:new_password] = words[0]
      respond_with :message,
        text: 'Повторите пароль'
      save_context :wait_for_new_password_confirmation
    end

    context_handler :wait_for_new_password_confirmation do |*words|
      if words[0] != session[:new_password]
        respond_with :message, text: 'Пароли не совпадают'
        return
      end
      sender.password = words[0]
      sender.password_confirmation = words[0]
      if sender.save
        respond_with :message, text: 'Пароль изменен'
      else
        respond_with :message, text: "Ошибка: #{sender.errors.full_messages.first}"
      end
    end
  end
end
