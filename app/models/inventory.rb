class Inventory < ActiveRecord::Base

  validates :available_in_city, :status, presence: true

  # Associations
  has_many :transactions
  belongs_to :book
  belongs_to :user
  
end
