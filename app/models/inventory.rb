class Inventory < ActiveRecord::Base
  attr_accessible :available_in_city, :book_deleted, :book_id, :commission, :condition_of_book, :status, :deleted_date, :no_of_borrows, :rental_price, :upload_date, :user_id

  validates :available_in_city, :rental_price, :status, presence: true

#Associations
  belongs_to :book
  belongs_to :user
  
end
