class AccrualService

  def self.call
    Resident.all.each do |resident|
      resident.amount = resident.current_amount + Settings.additional_amount.to_f * resident.rating
      resident.save
    end
  end

end
