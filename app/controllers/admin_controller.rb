class AdminController < ApplicationController
	include ApplicationHelper
	before_action :otp_verified?

	load_and_authorize_resource class: User

	def index
		@user = User.all
		chatbox()
	end

	def edit
		@profile = Profile.all
		chatbox()
	end

	def user_details
		@user = User.find(params[:user_id])
		chatbox()

		if @user.current_status == 'Locked'
			@locked = true
		end
	end

	def user_transaction_history
		@t_history =  Transaction.includes(:borrower, :lender).where('((borrower_id = ? OR lender_id = ? ) AND status = ? )', params[:id] , params[:id], 'Complete').order('request_date desc')
	end

	def bar_user
		@bar_user = User.find(params[:bar_user_id])

		if @bar_user.current_status != 'Locked'
			@bar_user.current_status  = 'Locked'

			if !@bar_user.save
				raise 'error'
			end

			respond_to do |format|
    		format.json { render nothing: true, status: 204 }
			end
		else
			respond_to do |format|
    		format.json { render nothing: true, status: 204 }
			end
		end

	end

	def unbar_user
		@unbar_user = User.find(params[:unbar_user_id])
		@unbar_user.current_status  = 'Active'

		if !@unbar_user.save
			raise 'error'
		end

		respond_to do |format|
    	format.json { render nothing: true, status: 204 }
		end
	end
end
