# Model Describing Chats
class Chat < ActiveRecord::Base
  attr_accessible :from_user, :transaction_id, :body

  validates :from_user, :transaction_id, :body, presence: :true

  belongs_to :transaction
end
