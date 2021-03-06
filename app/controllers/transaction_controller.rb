class TransactionController < ApplicationController
	include ApplicationHelper, TransactionHelper
	before_action :require_profile
	before_action :otp_verified?, except: [:user_id]
	before_action :require_address

	def create
		@transaction = Transaction.new
		@transaction.borrower_id = current_user.id
		@transaction.lender_id = params[:user_id] 
		@transaction.inventory_id = params[:inventory_id]
		@transaction.request_date = DateTime.now.to_time
		@transaction.renewal_count = 0
		@transaction.status = 'Pending'

		@borrow = Transaction.where('borrower_id = ? AND updated_at > ? AND status =?', current_user.id, Time.at(params[:after_b].to_i + 1), 'Pending')

		if !@transaction.save
			raise 'error'
		else
			#MailWorker.perform_borrow_request_async(@transaction.lender_id)
			lsa = @transaction.borrower.profile.last_seen_at
			if (DateTime.now.to_time - lsa).seconds < 6
				online_status = 'Online'
			else
				online_status = 'Offline'
			end

			transaction_details = [] 
			transaction_details << 'create'
			transaction_details << {
				id: @transaction.id,
				book_name: @transaction.inventory.book.book_name,
				requested_from: @transaction.inventory.address.address_summary,
				requested_date: @transaction.request_date.to_s(:long),
				status: @transaction.status,
				borrower: @transaction.borrower.full_name,
				delivery_mode: (@transaction.borrower.is_delivery or @transaction.lender.is_delivery),
				online: online_status,
				name: current_user.full_name
			}

			publish_channel = 'transaction_listener_' + @transaction.lender_id.to_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
			bigBertha_ref.push(transaction_details.to_json)

		end

		respond_to do |format|
    		format.js
		end
	end

	# Called when a lender accepts a request
	def update_request_status_accept
		accepted_request = Transaction.where(id: params[:tr_id]).take
		transaction_data = []
		transaction_data << params[:dispatch_date] << params[:dispatch_time]
		accepted_request_status = accepted_request.update_transaction('Accepted', current_user.id, *transaction_data)

		lender_id_s = accepted_request.lender_id.to_s
		borrower_id_s = accepted_request.borrower_id.to_s

		if accepted_request_status

			# Lender receives 10 requests for a book. Accepts One of them. Remaining 9 need to be rejected.
			@remaining_requests = Transaction.where(inventory_id: accepted_request.inventory_id, lender_id: accepted_request.lender_id, status: 'Pending')


			if !@remaining_requests.nil?
				@remaining_requests.each do |reject_each|
					if reject_each.id != accepted_request.id
						reject_each.rejection_date = DateTime.now.to_time
						reject_each.rejection_reason = 'Book Lent Out'
						reject_each.status = 'Rejected'

						reject_update_lender = []
						reject_update_lender << 'rejected_lender'
						reject_update_lender << {
							id: reject_each.id.to_s
						}

						reject_update_borrower = []
						reject_update_borrower << 'rejected_borrower'
						reject_update_borrower << {
							id: reject_each.id.to_s,
							book_name: accepted_request.inventory.book.book_name
						}

						if reject_each.save
							# Remove remaining requests rows from lender
							publish_channel_remaining_lender = 'transaction_listener_' + reject_each.lender_id.to_s
							bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel_remaining_lender)
      				bigBertha_ref.push(reject_update_lender.to_json)

							# Notify each of the remaining that request has been rejected
							publish_channel_remaining_borrower = 'transaction_listener_' + reject_each.borrower_id.to_s
							bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel_remaining_borrower)
      				bigBertha_ref.push(reject_update_borrower.to_json)
						end
					end
				end
			end


			# Once saved, push notifications to fb
	    #TODO Check for code optimization
	    book_name = accepted_request.inventory.book.book_name
	    acceptance_date = accepted_request.acceptance_date.to_s(:long)
	    delivery_mode = (accepted_request.borrower.is_delivery or accepted_request.lender.is_delivery)
	    currentcn = current_user.profile.chat_name
	    borrowercn = accepted_request.borrower.profile.chat_name
	    lendercn = accepted_request.lender.profile.chat_name
	    title = accepted_request.inventory.book.book_name
	    request_date = accepted_request.request_date.to_s(:long)

	    lsa_borrower = accepted_request.borrower.profile.last_seen_at
			if (DateTime.now.to_time - lsa_borrower).seconds < 6
				online_status_borrower = 'Online'
			else
				online_status_borrower = 'Offline'
			end

			transaction_accepted_lender = []
			transaction_accepted_lender << 'accepted_lender'
			transaction_accepted_lender << {			
				id: accepted_request.id,
				book_name: book_name,
				acceptance_date: acceptance_date,
				requested_date: request_date,
				borrower: accepted_request.borrower.full_name,
				delivery_mode: delivery_mode,
				borrower_id: accepted_request.borrower_id,
				online: online_status_borrower,
				currentcn: currentcn,
				lendercn: lendercn,
				borrowercn: borrowercn,
				title: title
			}

			lsa_lender = accepted_request.lender.profile.last_seen_at
			if (DateTime.now.to_time - lsa_lender).seconds < 6
				online_status_lender = 'Online'
			else
				online_status_lender = 'Offline'
			end

			transaction_accepted_borrower = []
			transaction_accepted_borrower << 'accepted_borrower'
			transaction_accepted_borrower << {
				id: accepted_request.id,
				book_name: book_name,
				acceptance_date: acceptance_date,
				requested_date: request_date,
				lender: accepted_request.lender.full_name,
				delivery_mode: delivery_mode,
				online: online_status_lender,
				currentcn: currentcn,
				lendercn: lendercn,
				borrowercn: borrowercn,
				title: title
			}

			
			#MailWorker.perform_borrow_accept_async(accepted_request.borrower_id)
			publish_channel_lender = 'transaction_listener_' + lender_id_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel_lender)
      bigBertha_ref.push(transaction_accepted_lender.to_json)

			publish_channel_borrower = 'transaction_listener_' + borrower_id_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel_borrower)
      bigBertha_ref.push(transaction_accepted_borrower.to_json)

		else
			raise 'error'
		end

		respond_to do |format|
    		format.json { render nothing: true, status: 204 }
		end
	end

	#TODO , check pattern mapping of rejected vs rejected lender and rejected borrower
	def update_request_status_reject
		rejected_transaction = Transaction.find(params[:tr_id])
		rejected_transaction_status = rejected_transaction.update_transaction('Reject', current_user.id, params[:reject_reason])
		
		# If saved, push notifications to fb
		if rejected_transaction_status
			transaction_rejected = []
			transaction_rejected << 'rejected'
			transaction_rejected << {
				id: rejected_transaction.id.to_s,
				book_name: rejected_transaction.inventory.book.book_name,
				reason: params[:reject_reason],
				name: rejected_transaction.lender.full_name
			}

			publish_channel = 'transaction_listener_' + rejected_transaction.borrower_id.to_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      bigBertha_ref.push(transaction_rejected.to_json)

			respond_to do |format|
	    		format.json { render nothing: true, status: 204 }
			end
		else
			respond_to do |format|
	    		format.json { render nothing: true, status: 403 }
			end
		end
	end

	def update_request_status_cancel
		cancelled_transaction = Transaction.where(id: params[:tr_id]).take
		cancelled_transaction_status = cancelled_transaction.update_transaction('Cancel', current_user.id, nil)
		
		if cancelled_transaction_status

			cancelled_transaction_details = []
			cancelled_transaction_details << 'cancelled'
			cancelled_transaction_details << {
				id: cancelled_transaction.id.to_s,
				book_name: cancelled_transaction.inventory.book.book_name,
			}

			publish_channel = 'transaction_listener_' + cancelled_transaction.lender_id.to_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      bigBertha_ref.push(cancelled_transaction_details.to_json)

			respond_to do |format|
	    		format.json { render nothing: true, status: 204 }
			end
		else
			respond_to do |format|
	    	format.json { render nothing: true, status: 403 }
			end		
		end
	end

	def update_request_status_return
		returned_transaction = Transaction.where(id: params[:tr_id]).take
		transaction_data = []
		transaction_data << params[:borrower_feedback].to_s << params[:borrower_comments].to_s << params[:returned_date].to_s << params[:return_time].to_s
		returned_transaction_status = returned_transaction.update_transaction('Returned', current_user.id, *transaction_data)
		full_name = returned_transaction.borrower.full_name

		if returned_transaction_status
			returned_transaction_details = []
			returned_transaction_details << 'returned'
			returned_transaction_details << {
				id: returned_transaction.id,
				returned_date: returned_transaction.returned_date.to_s(:long),
				book_name: returned_transaction.inventory.book.book_name,
				name: full_name,
				first_name: full_name.split[0]
			}

			publish_channel = 'transaction_listener_' + returned_transaction.lender_id.to_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      bigBertha_ref.push(returned_transaction_details.to_json)

			respond_to do |format|
    		format.json  { render nothing: true, status: 204 }
			end

		else
			respond_to do |format|
    		format.json  { render nothing: true, status: 403 }
			end
		end
	end

	def update_request_status_receive_lender
		received_transaction = Transaction.where(id: params[:tr_id]).take
		transaction_data = []
		transaction_data << params[:lender_feedback].to_s << params[:lender_comments]
		received_transaction_status = received_transaction.update_transaction('Complete', current_user.id, *transaction_data) 

		if received_transaction_status

			received_transaction_details = []
			received_transaction_details << 'received_lender'
			received_transaction_details << {
				id: received_transaction.id,
				book_name: received_transaction.inventory.book.book_name,
				name: received_transaction.lender.full_name
			}

			publish_channel = 'transaction_listener_' + received_transaction.borrower_id.to_s
			bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      bigBertha_ref.push(received_transaction_details.to_json)

			respond_to do |format|
    		format.json { render nothing: true, status: 204 }
			end
		end
	end

	def update_request_status_receive_borrower
		borrower_received_transaction = Transaction.where(id: params[:tr_id]).take
		borrower_received_transaction_status = borrower_received_transaction.update_transaction('Received Borrower', current_user.id, nil)
		full_name = borrower_received_transaction.borrower.full_name

		if borrower_received_transaction_status
			# If action initiated by borrower, push notification to lender, and vice versa
			if params[:called_by] == 'borrower'
				borrower_received_transaction_details = []
				borrower_received_transaction_details << 'received_borrower_by_borrower'
				borrower_received_transaction_details << {
					id: borrower_received_transaction.id,
					book_name: borrower_received_transaction.inventory.book.book_name,
					delivery_mode: (borrower_received_transaction.lender.is_delivery or borrower_received_transaction.borrower.is_delivery),
					received_date: borrower_received_transaction.received_date.to_s(:long),
					name: full_name,
					first_name: full_name.split[0],
					gender: borrower_received_transaction.borrower.profile.gender
				}

				publish_channel = 'transaction_listener_' + borrower_received_transaction.lender_id.to_s
				bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      	bigBertha_ref.push(borrower_received_transaction_details.to_json)

				borrower_received_transaction_lender_details = []
				borrower_received_transaction_lender_details << 'received_borrower_by_borrower_lender'
				borrower_received_transaction_lender_details << {
					id: borrower_received_transaction.id,
					received_date: borrower_received_transaction.received_date.to_s(:long),
				}

				publish_channel = 'transaction_listener_' + borrower_received_transaction.borrower_id.to_s
				bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      	bigBertha_ref.push(borrower_received_transaction_lender_details.to_json)

			elsif params[:called_by] == 'lender'
				borrower_received_transaction_details = []
				borrower_received_transaction_details << 'received_borrower_by_lender'
				borrower_received_transaction_details << {
					id: borrower_received_transaction.id,
					book_name: borrower_received_transaction.inventory.book.book_name,
					delivery_mode: (borrower_received_transaction.lender.is_delivery or borrower_received_transaction.borrower.is_delivery),
					received_date: borrower_received_transaction.received_date.to_s(:long),
					name: borrower_received_transaction.lender.full_name
				}

				publish_channel = 'transaction_listener_' + borrower_received_transaction.borrower_id.to_s
				bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      	bigBertha_ref.push(borrower_received_transaction_details.to_json)

				transaction_received_borrower_borrower = []
				transaction_received_borrower_borrower << 'received_borrower_by_lender_borrower'
				transaction_received_borrower_borrower << {
					id: borrower_received_transaction.id,
					received_date: borrower_received_transaction.received_date.to_s(:long)
				}

				publish_channel = 'transaction_listener_' + borrower_received_transaction.lender_id.to_s
				bigBertha_ref = Bigbertha::Ref.new(ENV['firebase_url'] + publish_channel)
      	bigBertha_ref.push(transaction_received_borrower_borrower.to_json)

			end
		end

		respond_to do |format|
    	format.json  { render json: { result: (borrower_received_transaction.lender.is_delivery or borrower_received_transaction.borrower.is_delivery),
    																name: borrower_received_transaction.borrower.profile.user_first_name,
    																gender: borrower_received_transaction.borrower.profile.gender } }
		end
	end

	def details
		if current_user.admin? || is_my_transaction(trans_id)
			@details = Transaction.find(params[:id])
		else
			flash[:alert] = 'No Such Transaction Exists'
			redirect_to home_path
		end
	rescue ActiveRecord::RecordNotFound
		redirect_to home_path
	end

	def user_id
		if params[:fbhandle]
			respond_to do |format|
				format.html  
				format.json { render json: { user_id: current_user.id.to_json, fburl: ENV['firebase_url'].to_json } }
			end
		else
			respond_to do |format|
				format.html  
				format.json { render json: { user_id: current_user.id.to_json } }
			end
		end
	end

	def history
		chatbox
		@t_history =  Transaction.includes(:inventory, :borrower, :lender).where('((borrower_id = ? OR lender_id = ? ) AND status = ? )', current_user.id , current_user.id, 'Complete').order('request_date desc').page(params[:page]).per(10)
	end

  private

  def require_profile
  	if current_user.profile.nil?
  		flash[:notice] = 'Please complete your profile'
  		redirect_to new_profile_path
  	else
  		return false
  	end
  end

  def require_address
  	if user_signed_in?
	  	if !current_user.profile.nil? && current_user.otp_verification
		    if current_user.addresses.empty?
		      flash[:notice] = 'Please Enter at least one Address'
		      redirect_to new_address_path
		    else
		      return false
		    end
		  end
		end
  end

end
