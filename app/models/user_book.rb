class UserBook < ActiveRecord::Base
  attr_accessible :book_detail_id, :user_id, :available_in_city, :rental_price, :availability

  validates :rental_price, :availability, :available_in_city, :presence => true
  

  #Associations
  belongs_to :book_detail
  belongs_to :user
  
end
