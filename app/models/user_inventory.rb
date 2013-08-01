class UserInventory < ActiveRecord::Base
  attr_accessible :available_in_city, :book_deleted, :book_detail_id, :commission, :condition_of_book, :current_status, :deleted_date, :no_of_borrows, :rental_price, :upload_date, :user_id

#Associations
  belongs_to :book_detail
  belongs_to :user
  
end