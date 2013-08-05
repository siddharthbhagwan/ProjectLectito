class TransactionController < ApplicationController
	before_filter :require_profile, :require_address

	def create
		@transaction = Transaction.new
		@transaction.borrower_id = current_user.id
		@transaction.lender_id = params[:user_id] 
		@transaction.inventory_id = params[:inventory_id]
		@transaction.status = "Pending"
		mail_to_id = params[:user_id]

		if !@transaction.save
			raise "error"
		else
			#MailWorker.perform_borrow_request_async(@transaction.lender_id)
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
			#MailWorker.perform_borrow_accept_async(@latest_accepted.borrower_id)
		else
			raise "error"
		end
	end


	def update_request_status_reject
		@latest_rejected = Transaction.find(params[:tr_id])
		@latest_rejected.status = params[:reject_reason]
		@latest_rejected.save
	end

	private

	def require_profile
    	if current_user.profile.nil?
    		flash[:notice] = "Please complete your profile"
    		redirect_to profile_edit_path
    	else
    		return false
    	end
  	end


	def require_address
    	if current_user.addresses.empty?
    		flash[:notice] = "Please Enter at least one Address"
    		redirect_to new_addres_path
    	else
    		return false
    	end
  	end
end
