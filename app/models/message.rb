class Message < ActiveRecord::Base

  belongs_to :user

  validates :user, presence: true
  validates :text, presence: true

  scope :ordered, -> { order(created_at: :desc) }

end
