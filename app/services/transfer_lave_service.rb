class TransferLaveService

  def self.call(sender, receiver, amount)
    ActiveRecord::Base.transaction do
      sender.amount = sender.current_amount - amount
      sender.save

      commission = amount * (Settings.commission.to_f / 100)
      actual_amount = amount - commission

      master_account = Resident.find_by(telegram_username: Settings.master_account)
      master_account.amount = master_account.current_amount + commission
      master_account.save

      receiver.amount = receiver.current_amount + actual_amount
      receiver.save

      Transaction.create(
        receiver_id: receiver.id,
        sender_id: sender.id,
        amount: amount
      )
    end
    true
  end

end
