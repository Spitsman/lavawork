class AccrualService

  def self.call
    User.all.each do |user|
      coefficient = user.coefficient
      additional_amount = Settings.additional_amount.to_f * user.rating * coefficient

      if additional_amount > 0
        user.change_amount! additional_amount
        coefficient_text = ", твой коэфициент начисления: #{coefficient}" if coefficient > 1
        text = "Тебе начислено #{additional_amount}l (по #{Settings.additional_amount}lv за каждый балл рейтинга#{coefficient_text})"

        Telegram.bot.send_message(
          chat_id: user.telegram_id,
          text: text
        )
      end
    end
  end

end
