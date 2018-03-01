class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include CallbackQueryContext

  skip_before_action :verify_authenticity_token, :require_user
  before_action :require_resident, only: [:lava, :voting, :send_lava]
  before_action :create_message
  # before_action :update_telegram_username, except: :start

  def create_message
    if sender
      sender.messages.create(text: payload['text'])
    end
  end

  def require_resident
    unless sender
      respond_with :message, text: 'Вы не являетесь резидентом Lava' and return false
    end
  end

  def update_telegram_username
    unless sender&.telegram_username
      sender.update_attribute(:telegram_username, from['username'])
    end
  end

  def send_lava
    respond_with :message,
      text: "Укажите получателя",
      reply_markup: {
        inline_keyboard: User.residents.where.not(id: sender.id).ordered.map do |r|
          [ text: r.decorate.display_name, callback_data: "resident:#{{ id: r.id, name: r.decorate.display_name }.to_json}" ]
        end
      }
  end

  def resident_callback_query(data)
    data_hash = JSON.parse(data)
    session[:receiver] = data_hash['id']
    save_context :wait_for_lava
    edit_message :text, text: "Выбранный резидент: #{data_hash['name']}"
    respond_with :message, text: 'Укажите количество лаве'
  end

  context_handler :wait_for_lava do |*words|
    receiver = User.residents.find(session[:receiver])
    amount = words[0].to_i
    result = TransferLaveService.new(sender, receiver, amount).call

    if result.first
      session.clear
    else
      save_context :wait_for_lava
    end

    respond_with :message, text: result.second
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
        text: "Привет, друг! Нажми кнопку ниже чтоб прислать мне свой контакт.",
        reply_markup: { keyboard: [[{request_contact: true, text: 'Отправить контакт'}]], resize_keyboard: true }
    end
  end

  context_handler :wait_for_contact do |*words|
    unless payload['contact'].present?
      save_context :wait_for_contact
      respond_with :message, text: 'Просто пришли контакт'
      return
    end

    resident = User.residents.new(
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
          User.residents.where.not(id: sender).ordered.map do |r|
            [ text: "#{r.decorate.display_name} – #{r.likers_count} #{'👍' if r.liked_by?(sender)}", callback_data: "voting:#{{id: r.id}.to_json}" ]
          end
      }
  end

  def voting_callback_query(data)
    data_hash = JSON.parse(data)
    res = User.residents.find(data_hash['id'])
    sender.toggle_like! res
    edit_message :text,
      text: "Ты проголосовал за: #{res.decorate.display_name}",
      reply_markup: {
        inline_keyboard:
          User.residents.where.not(id: sender).ordered.map do |r|
            [ text: "#{r.decorate.display_name} – #{r.likers_count} #{'👍' if r.liked_by?(sender)}", callback_data: "voting:#{{id: r.id}.to_json}" ]
          end
      }
  end

  def lava
    respond_with :message,
      text: "Баланс – #{sender.current_amount&.round(2)} lava
Голосов – #{sender.likers_count}
Рейтинг – #{sender.rating}"
  end

  protected

  def sender
    @sender ||= User.residents.find_by(telegram_id: from['id'])
  end

end
