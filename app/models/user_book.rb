class UserBook < ActiveRecord::Base
  attr_accessible :book_detail_id, :user_id

  #Associations
  belongs_to :book_detail
  belongs_to :user
end
