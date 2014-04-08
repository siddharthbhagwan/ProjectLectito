# Model Describing Chats
class Chat < ActiveRecord::Base

  validates :from_user, :transaction_id, :body, presence: :true

  # Association
  
  belongs_to :transaction

end
