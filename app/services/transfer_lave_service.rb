class TransferLaveService

  def initialize(sender, receiver, amount)
    @sender = sender; @receiver = receiver; @amount = amount.to_f
    @commission = @amount * (Settings.commission.to_f / 100)
    @amount_with_commission = @amount + @commission
  end

  def call
    validation_result = validate
    return validation_result unless validation_result.first
    process
  end

private

  def validate
    return [false, 'Неверное значение'] if @amount <= 0
    return [false, "У вас не хватает средств, для совершения операции требуется #{@amount_with_commission} lv"] if @sender.current_amount < @amount_with_commission
    [true, 'ok']
  end

  def process
    transaction = Transaction.new(
      receiver_id: @receiver.id,
      sender_id: @sender.id,
      amount: @amount,
      commission: @commission,
    )

    ActiveRecord::Base.transaction do
      @sender.change_amount!   -@amount_with_commission
      Settings.change_amount!   @commission
      @receiver.change_amount! @amount
      transaction.save

      # Telegram.bot.send_message(chat_id: @receiver.telegram_id,
        # text: "Резидент #{@sender.decorate.display_name} перечислил вам #{@amount} lv")
    end

    [true, "#{Russian.pluralize(@amount, 'Перечислен', 'Перечислено', 'Перечислено')} #{@amount} lv пользователю #{@receiver.decorate.display_name}, комиссия: #{@commission} lv", transaction]
  rescue Exception => e
    [false, "Ошибка: #{e}"]
  end
end
