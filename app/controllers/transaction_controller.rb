class TransactionController < ApplicationController

	def create
		@transaction = Transaction.new
		@transaction.borrower_id = current_user.id
		@transaction.lender_id = params[:user_id] 
		@transaction.user_book_id = params[:user_book_id]
		@transaction.status = "Pending"

		@transaction.save

		@borrow = Transaction.where("borrower_id = ? and updated_at > ?", current_user.id, Time.at(params[:after_b].to_i + 1))

		respond_to do |format|
    		format.html  
    		format.js
  		end
	end


	def get_latest_borrowed
		@borrow = Transaction.where("borrower_id = ? and updated_at > ?", current_user.id, Time.at(params[:after].to_i + 1))
	end


	def get_latest_lent
		@lent = Transaction.where("lender_id = ? and updated_at > ?", current_user.id, Time.at(params[:after].to_i + 1))	
	end
end
