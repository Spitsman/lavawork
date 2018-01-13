class Transaction < ActiveRecord::Base

  belongs_to :sender, class_name: 'Resident', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'Resident', foreign_key: :receiver_id

  validates :sender, presence: true
  validates :receiver, presence: true
  validates :amount, presence: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_last_month, -> { where("created_at > '#{(Date.today - 1.month).strftime('%m.%d.%Y')}'") }

end
