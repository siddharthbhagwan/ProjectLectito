class TransactionController < ApplicationController

	def create
		@transaction = Transaction.new
		@transaction.borrower_id = current_user.id
		@transaction.lender_id = params[:user_id] 
		@transaction.user_book_id = params[:user_book_id]
		@transaction.status = "Pending"
		mail_to_id = params[:user_id]

		if !@transaction.save
			raise "error"
		else
			MailWorker.perform_async(@transaction.lender_id)#, User.find(@transaction.lender_id).profile.user_first_name)
		end

		@borrow = Transaction.where("borrower_id = ? AND updated_at > ?", current_user.id, Time.at(params[:after_b].to_i + 1))

		respond_to do |format|
    		format.html  
    		format.js
  		end
	end


	def get_latest_borrowed
		@latest_borrowed = Transaction.where("borrower_id = ? AND status = ? AND updated_at > ?", current_user.id, "Pending", Time.at(params[:after].to_i + 1))
	end


	def get_latest_lent
		@latest_lent = Transaction.where("lender_id = ? AND status = ? AND updated_at > ?", current_user.id, "Pending", Time.at(params[:after].to_i + 1))	
	end


	def update_request_status_accept
		@latest_accepted = Transaction.find(params[:tr_id])
		@latest_accepted.status = "Accepted"
		
		if @latest_accepted.save
			MailWorker.perform_async(@latest_accepted.borrower_id)
		else
			raise "error"
		end
	end


	def update_request_status_reject
		@latest_rejected = Transaction.find(params[:tr_id])
		@latest_rejected.status = params[:reject_reason]
		@latest_rejected.save
	end
end
