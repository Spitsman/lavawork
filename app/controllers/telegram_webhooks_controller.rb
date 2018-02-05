class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include CallbackQueryContext

  skip_before_action :verify_authenticity_token, :require_user
  before_action :require_resident, only: [:lave, :voting, :send_lave]
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

  def send_lave
    respond_with :message,
      text: "Укажите получателя",
      reply_markup: {
        inline_keyboard: Resident.where.not(id: sender.id).ordered.map do |r|
          [ text: r.decorate.display_name, callback_data: "resident:#{{ id: r.id, name: r.decorate.display_name }.to_json}" ]
        end
      }
  end

  def resident_callback_query(data)
    data_hash = JSON.parse(data)
    receiver = Resident.find(data_hash['id'])
    session[:receiver] = data_hash['id']
    save_context :wait_for_lave
    edit_message :text, text: "Выбранный резидент: #{data_hash['name']}"
    respond_with :message, text: 'Укажите количество лаве'
  end

  context_handler :wait_for_lave do |*words|
    amount = words[0].to_i
    response = if amount <= 0
      save_context :wait_for_days
      'Неверное значение'
    elsif sender.current_amount < amount
      save_context :wait_for_lave
      'У вас не хватает лаве'
    else
      receiver = Resident.find(session[:receiver])
      TransferLaveService.call(sender, receiver, amount)
      session.clear

      commission = amount * (Settings.commission.to_f / 100)
      actual_amount = amount - commission

      "#{Russian.pluralize(amount, 'Перечислен', 'Перечислено', 'Перечислено')} #{actual_amount} лаве пользователю #{receiver.decorate.display_name}, комиссия: #{Settings.commission}%"
    end
    respond_with :message, text: response
  end

  def cancel
    session.clear
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
      telegram_id: payload['contact']['user_id'],
      telegram_username: from['username'],
      amount: 0
    )
    if resident.save
      respond_with :message, text: 'Ты успешно зарегистрировался', reply_markup: { remove_keyboard: true }
    else
      save_context :wait_for_contact
      respond_with :message, text: "Ошибка: #{resident.errors.full_messages.first}. Заполни контактные данные и попробуй еще раз."
    end
  end

  def voting
    respond_with :message,
      text: 'Голосуй за коворкеров',
      reply_markup: {
        inline_keyboard:
          Resident.where.not(id: sender).ordered.map do |r|
            [ text: "#{r.decorate.display_name} – #{r.likers_count} #{'👍' if r.liked_by?(sender)}", callback_data: "voting:#{{id: r.id}.to_json}" ]
          end
      }
  end

  def voting_callback_query(data)
    data_hash = JSON.parse(data)
    res = Resident.find(data_hash['id'])
    sender.toggle_like! res
    edit_message :text,
      text: "Ты проголосовал за: #{res.decorate.display_name}",
      reply_markup: {
        inline_keyboard:
          Resident.where.not(id: sender).ordered.map do |r|
            [ text: "#{r.decorate.display_name} – #{r.likers_count} #{'👍' if r.liked_by?(sender)}", callback_data: "voting:#{{id: r.id}.to_json}" ]
          end
      }
  end

  def lave
    respond_with :message,
      text: "Баланс – #{sender.current_amount&.round(2)} lava
Голосов – #{sender.likers_count}
Рейтинг – #{sender.rating}"
  end

  protected

  def sender
    @sender ||= Resident.find_by(telegram_id: from['id'])
  end

end
