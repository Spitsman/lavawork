class Resident < ActiveRecord::Base

  validates :phone, uniqueness: { allow_nil: true, allow_blank: true }, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :telegram_id, uniqueness: { allow_nil: true, allow_blank: true }
  validates_numericality_of :days, only_integer: true, greater_than_or_equal_to: 0

  has_many :sent_transactions, class_name: 'Transaction', foreign_key: :sender_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :receiver_id
  has_many :messages

  scope :active, -> { where(active: true) }
  scope :active_first, -> { order("CASE active WHEN true THEN 1 ELSE 2 END") }

  before_validation do
    self.telegram_id = nil if self.telegram_id.blank?
  end

  def days
    return 0 if self.expire_at.nil? || self.expire_at < Date.today
    (self.expire_at - Date.today).to_i
  end

  def days=(value)
    self.expire_at = Date.today + value.to_i.days
  end

  def increment_days!(count)
    self.expire_at += count.days
    save
  end

  def decrement_days!(count)
    self.expire_at -= count.days
    save
  end

end
