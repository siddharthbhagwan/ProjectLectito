class Inventory < ActiveRecord::Base

  validates :available_in_city, :status, presence: true

  # Associations
  has_many :transactions
  belongs_to :book
  belongs_to :user
  belongs_to :address, foreign_key: :available_in_city

  def self.find_current
    where(deleted: :false)
  end

end
