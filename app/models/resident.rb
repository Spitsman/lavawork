class Resident < ActiveRecord::Base

  acts_as_likeable
  acts_as_liker

  validates :phone, uniqueness: { allow_nil: true, allow_blank: true }, presence: true
  validates :first_name, presence: true

  validates :telegram_id, uniqueness: { allow_nil: true, allow_blank: true }

  has_many :sent_transactions, class_name: 'Transaction', foreign_key: :sender_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :receiver_id
  has_many :messages, dependent: :destroy

  scope :ordered, -> { order(created_at: :desc) }
  scope :active, -> { where(active: true) }
  scope :active_first, -> { order("CASE active WHEN true THEN 1 ELSE 2 END") }

  before_validation do
    self.telegram_id = nil if self.telegram_id.blank?
  end

  before_save if: -> (obj) { 'amount'.in? obj.changes.keys } do
    # touch(:amount_changed_at)
    self.amount_changed_at = Time.current
  end

  def reputation
    self.likers(Resident).reduce(0){|sum,r| sum += r.likers_count}
  end

  def rating
    reputation + likers_count
  end

  def current_amount
    return 0 if self.amount.nil? || self.amount_changed_at.nil?
    self.amount * ((1 - Settings.demurrage.to_f/100) ** ((DateTime.now.to_i - self.amount_changed_at.to_i)/(24*60*60)))
  end

  def change_amount!(amount)
    self.amount = self.current_amount + amount
    self.save
  end

end
