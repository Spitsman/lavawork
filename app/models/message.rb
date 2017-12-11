class Message < ActiveRecord::Base

  belongs_to :resident

  validates :resident, presence: true
  validates :text, presence: true

  scope :ordered, -> { order(created_at: :desc) }

end
