class Transaction < ActiveRecord::Base
  attr_accessible :borrower_id, :lender_id, :status, :user_book_id

  belongs_to :borrower, class_name: "User"
  belongs_to :lender, class_name: "User"
end
