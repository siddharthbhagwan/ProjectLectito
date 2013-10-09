class TransactionController < ApplicationController

	before_action :require_profile, :require_address

	Firebase.base_uri = "https://projectlectito.firebaseio.com/"

	def create
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
			transaction_details << "create"
			transaction_details << {
				:id => @transaction.id,
				:book_name => Book.find(Inventory.find(@transaction.inventory_id).book_id).book_name,
				:requested_from => Address.find(Inventory.find(@transaction.inventory_id).available_in_city).address_summary,
				:requested_date => @transaction.request_date.to_s(:long),
				:status => @transaction.status,
				:borrower => User.find(@transaction.borrower_id).full_name,
				:delivery_mode => User.find(@transaction.borrower_id).is_delivery
			}

			publish_channel = "transaction_listener_" + @transaction.lender_id.to_s
			Firebase.push(publish_channel, transaction_details.to_json)

		end

		respond_to do |format|
    		format.html  
    		format.js
		end
	end


	def update_request_status_accept
		@accept_request = Transaction.where(:id => params[:tr_id]).take	
		@accept_request.status = "Accepted"
		@accept_request.acceptance_date = DateTime.now.to_time
		@accept_request.accept_pickup_date = params[:dispatch_date] + ", " + params[:dispatch_time]
		#@accept_request.returned_date = 15.days.from_now

		lender_id_s = @accept_request.lender_id.to_s
		borrower_id_s = @accept_request.borrower_id.to_s

		@remaining_requests = Transaction.where(:inventory_id => @accept_request.inventory_id, :lender_id => @accept_request.lender_id, :status => "Pending")


		if !@remaining_requests.nil?
			@remaining_requests.each do |reject_each|
				if reject_each.id != @accept_request.id
					reject_each.rejection_date = DateTime.now.to_time
					reject_each.rejection_reason = "Book Lent Out"
					reject_each.status = "Rejected"

					reject_update_lender = Array.new
					reject_update_lender << "rejected_lender"
					reject_update_lender << {
						:id => reject_each.id.to_s
					}

					reject_update_borrower = Array.new
					reject_update_borrower << "rejected_borrower"
					reject_update_borrower << {
						:id => reject_each.id.to_s
					}

					if reject_each.save
						publish_channel_remaining_lender = "transaction_listener_" + reject_each.lender_id.to_s
						Firebase.push(publish_channel_remaining_lender, reject_update_lender.to_json)

						publish_channel_remaining_borrower = "transaction_listener_" + reject_each.borrower_id.to_s
						Firebase.push(publish_channel_remaining_borrower, reject_update_borrower.to_json)
					end
				end
			end
		end


		transaction_accepted_lender = Array.new
		transaction_accepted_lender << "accepted_borrower"
		transaction_accepted_lender << {			
			:id => @accept_request.id,
			:book_name => Book.find(Inventory.find(@accept_request.inventory_id).book_id).book_name,
			:acceptance_date => @accept_request.acceptance_date.to_s(:long),
			:borrower => User.find(@accept_request.borrower_id).full_name,
			:delivery_mode => User.find(@accept_request.borrower_id).is_delivery
		}

		transaction_accepted_borrower = Array.new
		transaction_accepted_borrower << "accepted_lender"
		transaction_accepted_borrower << {
			:id => @accept_request.id,
			:book_name => Book.find(Inventory.find(@accept_request.inventory_id).book_id).book_name,
			:acceptance_date => @accept_request.acceptance_date.to_s(:long),
			:lender => User.find(@accept_request.lender_id).full_name,
			:delivery_mode => User.find(@accept_request.borrower_id).is_delivery
		}

		if @accept_request.save
			#MailWorker.perform_borrow_accept_async(@accept_request.borrower_id)
			publish_channel_lender = "transaction_listener_" + lender_id_s
			Firebase.push(publish_channel_lender, transaction_accepted_lender.to_json)

			publish_channel_borrower = "transaction_listener_" + borrower_id_s
			Firebase.push(publish_channel_borrower, transaction_accepted_borrower.to_json)

		else
			raise "error"
		end
	end

	#TODO , check pattern mapping of rejected vs rejected lender and rejected borrower
	def update_request_status_reject
		@latest_rejected = Transaction.where(:id => params[:tr_id]).take	
		@latest_rejected.status = "Rejected"
		@latest_rejected.rejection_date = DateTime.now.to_time
		@latest_rejected.rejection_reason = params[:reject_reason]

		transaction_rejected = Array.new
		transaction_rejected << "rejected"
		transaction_rejected << {
			:id => @latest_rejected.id.to_s,
			:book_name => Book.find(Inventory.find(@latest_rejected.inventory_id).book_id).book_name,
		}

		if @latest_rejected.save
			publish_channel = "transaction_listener_" + @latest_rejected.borrower_id.to_s
			Firebase.push(publish_channel, transaction_rejected.to_json)
		end
	end

	def update_request_status_cancel
		@cancel_transaction = Transaction.where(:id => params[:tr_id]).take
		@cancel_transaction.status = "Cancelled"

		cancelled_transaction = Array.new
		cancelled_transaction << "cancelled"
		cancelled_transaction << {
			:id => @cancel_transaction.id.to_s,
			:book_name => Book.find(Inventory.find(@cancel_transaction.inventory_id).book_id).book_name,
		}
		
		if @cancel_transaction.save
			publish_channel = "transaction_listener_" + @cancel_transaction.lender_id.to_s
			Firebase.push(publish_channel, cancelled_transaction.to_json)
		end
	end

	def update_request_status_return
		@return_transaction = Transaction.where(:id => params[:tr_id]).take
		@return_transaction.status = "Returned"
		@return_transaction.returned_date = DateTime.now.to_time
		@return_transaction.return_pickup_date = params[:return_date] + ", " + params[:return_time]
		
		returned_transaction = Array.new
		returned_transaction << "returned"
		returned_transaction << {
			:id => @return_transaction.id,
			:returned_date => @return_transaction.returned_date.to_s(:long),
			:book_name => Book.find(Inventory.find(@return_transaction.inventory_id).book_id).book_name
		}

		if @return_transaction.save
			publish_channel = "transaction_listener_" + @return_transaction.lender_id.to_s
			Firebase.push(publish_channel, returned_transaction.to_json)
		else
			raise 'error'
		end

	end

	def update_request_status_receive
		@received_transaction = Transaction.where(:id => params[:tr_id]).take
		@received_transaction.return_received_date = DateTime.now.to_time
		@received_transaction.lender_feedback = params[:lender_feedback] 
		@received_transaction.lender_comments = params[:lender_comments]
		@received_transaction.status = "Complete"

		if @received_transaction.save
			@received_inventory = Inventory.where(:id => @received_transaction.inventory_id).take
			@received_inventory.status = "Available"
			@received_inventory.save

			transaction_received = Array.new
			transaction_received << "received"
			transaction_received << {
				:id => @received_transaction.id,
				:book_name => Book.find(Inventory.find(@received_transaction.inventory_id).book_id).book_name
			}

			publish_channel = "transaction_listener_" + @received_transaction.borrower_id.to_s
			Firebase.push(publish_channel, transaction_received.to_json)

		end
	end

	def new_chat
		chat = Chat.new
	    chat.transaction_id = params[:ref]
	    chat.body = params[:chat] + "\n"
	    chat.from_user = current_user.id

	    if chat.save
	      transaction = Transaction.where(:id => params[:ref]).take
	      if current_user.id == transaction.lender_id	  
	        publish_from_channel = "transaction_listener_" + transaction.lender_id.to_s
	        publish_to_channel = "transaction_listener_" + transaction.borrower_id.to_s
	      else
	        publish_from_channel = "transaction_listener_" + transaction.borrower_id.to_s
	        publish_to_channel = "transaction_listener_" + transaction.lender_id.to_s
	      end

	      chat_data = Array.new
	      chat_data << "chat"
	      chat_data << {
	        :text => params[:chat],
	        :trid => params[:ref],
	        :title => params[:title],
	        :you => params[:you],
	        :other => params[:other],
	        :type => params[:type]
	      }

				#Firebase.push(publish_from_channel, chat_data.to_json)
	      response = Firebase.push(publish_to_channel, chat_data.to_json)
	      render nothing: true
	    else
      		raise 'error'
    	end
	end

	def user_id
		respond_to do |format|
			format.html  
			format.json { render :json => { :user_id => current_user.id.to_json} }
		end	
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