class AccrualService

  def self.call
    Resident.all.each do |resident|
      additional_amount = Settings.additional_amount.to_f * resident.rating
      resident.amount = resident.current_amount + additional_amount
      resident.save

      Telegram.bot.send_message(
        chat_id: resident.telegram_id,
        text: "Тебе начислено #{additional_amount}l (по #{Settings.additional_amount}l за каждый балл рейтинга)"
      ) if additional_amount > 0
    end
  end

end
