class Chat < ActiveRecord::Base
	attr_accessible :from_user, :transaction_id, :body

	belongs_to :transaction
end