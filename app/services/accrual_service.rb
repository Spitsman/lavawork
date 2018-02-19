class AccrualService

  def self.call
    Resident.all.each do |resident|
      coefficient = resident.coefficient
      additional_amount = Settings.additional_amount.to_f * resident.rating * coefficient

      if additional_amount > 0
        resident.change_amount! additional_amount
        coefficient_text = ", твой коэфициент начисления: #{coefficient}" if coefficient > 1
        text = "Тебе начислено #{additional_amount}l (по #{Settings.additional_amount}lv за каждый балл рейтинга#{coefficient_text})"

        Telegram.bot.send_message(
          chat_id: resident.telegram_id,
          text: text
        )
      end
    end
  end

end
