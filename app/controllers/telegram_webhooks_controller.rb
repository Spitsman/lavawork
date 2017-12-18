class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  skip_before_action :verify_authenticity_token, :require_user
  before_action :require_resident, only: [:days, :residents, :send_days]
  before_action :create_message
  # before_action :update_telegram_username, except: :start

  def create_message
    if sender
      sender.messages.create(text: payload['text'])
    end
  end

  def require_resident
    unless sender
      respond_with :message, text: 'Вы не являетесь резидентом коворкинга' and return false
    end
  end

  def update_telegram_username
    unless sender&.telegram_username
      sender.update_attribute(:telegram_username, from['username'])
    end
  end

  def send_days
    save_context :send_days
    respond_with :message, text: "Укажите telegram-логин получателя"
  end

  context_handler :send_days do |*words|
    receiver = Resident.find_by(telegram_username: words[0])
    response = if receiver.present?
      if receiver != sender
        session[:receiver] = words[0]
        save_context :wait_for_days
        'Укажите количество дней'
      else
        save_context :send_days
        'Нельзя переводить дни самому себе'
      end
    else
      save_context :send_days
      'Получатель не найден. Просмотрите список резидентов командой /residents или введите /cancel для отмены.'
    end
    respond_with :message, text: response
  end

  context_handler :wait_for_days do |*words|
    days = words[0].to_i
    response = if days <= 0
      save_context :wait_for_days
      'Неверное значение'
    elsif sender.days < days
      save_context :wait_for_days
      'У вас не хватает дней'
    else
      receiver = Resident.find_by(telegram_username: session[:receiver])
      TransferDaysService.call(sender, receiver, days)
      session[:receiver] = nil
      "Перечислено #{days} дней пользователю #{receiver.decorate.display_name}"
    end
    respond_with :message, text: response
  end

  def cancel
    session[:receiver] = nil
    session[:first_name] = nil
    session[:last_name] = nil
    respond_with :message, text: 'OK'
  end

  def message(msg)
    response = ["У тебя все получится, детка, ебашь!",
                "Короче расслабься",
                "К тебе или ко мне?",
                "Ну шо епта",
                "Коворкинг - это образ жизни",
                "Просто напиши ей/ему",
                "Держи вкурсе",
                "Ave Maria - Deus Vult",
                "Ой, да займись ты уже делом",
                "продолжай",
                "ладно, поигрались и хватит. Надоел уже!"].sample

    respond_with :message, text: response
  end

  def start(data = nil, *)
    if sender.present?
      respond_with :message, text: "Привет, #{sender.first_name}!"
    else
      save_context :wait_for_contact
      respond_with :message,
        text: "Привет, друг! Пришли мне свой контакт чтоб я мог тебя запомнить.",
        reply_markup: { keyboard: [[{request_contact: true, text: 'Отправить контакт'}]], resize_keyboard: true }
    end
  end

  context_handler :wait_for_contact do |*words|
    unless payload['contact'].present?
      save_context :wait_for_contact
      respond_with :message, text: 'Просто пришли контакт'
      return
    end

    resident = Resident.new(
      first_name: payload['contact']['first_name'],
      last_name: payload['contact']['last_name'],
      phone: payload['contact']['phone_number'],
      expire_at: Date.today + 1.day,
      telegram_id: payload['contact']['user_id'],
      telegram_username: from['username']
    )
    if resident.save
      respond_with :message, text: 'Ты успешно зарегистрировался, у тебя 1 день коворкинга', reply_markup: { remove_keyboard: true }
    else
      save_context :wait_for_contact
      respond_with :message, text: "Ошибка: #{resident.errors.full_messages.first}. Заполни контактные данные и попробуй еще раз."
    end
  end

  def residents
    response = Resident.all.decorate.reduce(""){|memo, r| memo << r.display_name_with_telegram_username << "\n"}
    respond_with :message, text: response
  end

  def days
    response = "У вас #{Russian.pluralize(sender.days, 'остался', 'осталось', 'осталось')} #{sender.days} #{Russian.pluralize(sender.days, 'день', 'дня', 'дней')} коворкинга"
    respond_with :message, text: response
  end

  protected

  def sender
    @sender ||= Resident.find_by(telegram_id: from['id'])
  end

end