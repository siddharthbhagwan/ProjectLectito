class TransactionController < ApplicationController
include ActionController::Live

	before_action :require_profile, :require_address

	def create
		response.headers["Content-Type"] = 'text/javascript'
		@transaction = Transaction.new
		@transaction.borrower_id = current_user.id
		@transaction.lender_id = params[:user_id] 
		@transaction.inventory_id = params[:inventory_id]
		@transaction.request_date = DateTime.now.to_time
		@transaction.renewal_count = 0
		@transaction.status = "Pending"

		@borrow = Transaction.where("borrower_id = ? AND updated_at > ? AND status =?", current_user.id, Time.at(params[:after_b].to_i + 1), "Pending")

		if !@transaction.save
			raise "error"
		else
			#MailWorker.perform_borrow_request_async(@transaction.lender_id)
			transaction_details = Array.new 
			transaction_details << {
			:id => @transaction.id,
			:updated_at => @transaction.updated_at.to_i,
			:book_name => Book.find(Inventory.find(@transaction.inventory_id).book_id).book_name,
			:requested_from => Address.find(Inventory.find(@transaction.inventory_id).available_in_city).address_summary,
			:requested_date => @transaction.request_date.to_s(:long),
			:status => @transaction.status
			}

			publish_channel = "transaction_created_" + @transaction.lender_id.to_s

			$redis.publish(publish_channel, transaction_details.to_json)
		end	
		ensure
			$redis.quit

		respond_to do |format|
    		format.html  
    		format.js
  		end
	end

	def latest_lent
		response.headers["Content-Type"] = "text/event-stream"
		subscribe_channel = "transaction_created_" + current_user.id.to_s
		redis_subscribe = Redis.new
		redis_subscribe.subscribe(subscribe_channel) do |on|
			on.message do |event, data|
		        response.stream.write("event: #{event}\n")
		        response.stream.write("data: #{data}\n\n")
		  	end
		end
	rescue IOError
		logger.info "Stream Closed"
	ensure
		redis_subscribe.quit
		response.stream.close
	end


	def update_request_status_accept
		@latest_accepted = Transaction.find(params[:tr_id])
		@latest_accepted.status = "Accepted"
		@latest_accepted.acceptance_date = DateTime.now.to_time
		
		if @latest_accepted.save
			#MailWorker.perform_borrow_accept_async(@latest_accepted.borrower_id)
		else
			raise "error"
		end
	end

	def update_request_status_reject
		@latest_rejected = Transaction.where(:id => params[:tr_id]).take	
		@latest_rejected.status = params[:reject_reason]
		@latest_rejected.save
	end

	def update_request_status_cancel
		response.headers["Content-Type"] = 'text/javascript'
		@cancel_transaction = Transaction.where(:id => params[:tr_id]).take
		@cancel_transaction.status = "Cancelled"
		
		if @cancel_transaction.save
			publish_channel = "transaction_cancelled_" + @cancel_transaction.lender_id.to_s
			$redis.publish(publish_channel, @cancel_transaction.id)
		end
	ensure
		$redis.quit
	end

	def latest_cancelled
		response.headers["Content-Type"] = "text/event-stream"
		subscribe_channel = "transaction_cancelled_" + current_user.id.to_s
		redis_subscribe = Redis.new
		redis_subscribe.subscribe(subscribe_channel) do |on|
			on.message do |event, data|
		        response.stream.write("event: #{event}\n")
		        response.stream.write("data: #{data}\n\n")
		  	end
		end
	rescue IOError
		logger.info "Stream Closed"
	ensure
		redis_subscribe.quit
		response.stream.close
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
    		redirect_to new_address_path
    	else
    		return false
    	end
  	end

end