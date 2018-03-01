class Transaction < ActiveRecord::Base

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :commission_holder, class_name: 'User', foreign_key: :commission_holder_id

  validates :sender, presence: true
  validates :receiver, presence: true
  validates :amount, presence: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_last_month, -> { where("created_at > '#{1.month.ago}'") }

end
