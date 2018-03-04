class User < ActiveRecord::Base

  self.inheritance_column = nil

  acts_as_likeable
  acts_as_liker

  enum type: {resident: 'resident', admin: 'admin'}

  acts_as_authentic do |c|
    c.login_field = :phone
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end

  validates :phone, uniqueness: { allow_nil: true, allow_blank: true }, presence: true
  validates :first_name, presence: true

  validates :telegram_id, uniqueness: { allow_nil: true, allow_blank: true }

  has_many :sent_transactions, class_name: 'Transaction', foreign_key: :sender_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :receiver_id
  has_many :messages, dependent: :destroy

  scope :ordered, -> { order(created_at: :desc) }
  scope :active_first, -> { order("CASE active WHEN true THEN 1 ELSE 2 END") }
  scope :residents, -> { where(type: 'resident') }
  scope :admins, -> { where(type: 'admin') }

  before_validation do
    self.telegram_id = nil if self.telegram_id.blank?
    self.phone.gsub!('+', '')
  end

  before_save if: -> (obj) { 'amount'.in? obj.changes.keys } do
    self.amount_changed_at = Time.current
  end

  def coefficient
    position = self.class.order(id: :asc).pluck(:id).index(self.id) + 1
    h = {1..10=>100, 11..100=>50, 101..1000=>20, 1001..10_000=>10, 10_001..100_000=>5, 100_001..1_000_000=>2, 1_000_001..1_000_000_000=>1}
    h.select{|ary| position.in? ary}.values.first
  end

  def reputation
    self.likers(self.class).reduce(0){|sum,r| sum += r.likers_count}
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
