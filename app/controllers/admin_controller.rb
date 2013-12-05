class AdminController < ApplicationController
	include ApplicationHelper

	load_and_authorize_resource :class => User

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

		if @user.current_status == "Locked"
			@locked = true
		end
	end

	def bar_user
		@bar_user = User.find(params[:bar_user_id])

		if current_user.id == params[:bar_user_id].to_i

			respond_to do |format|
	    		format.html  
	    		format.json { render :json => "Admin cant Lock itself" }
	  		end

		else
			if @bar_user.current_status != "Locked"
				@bar_user.current_status  = "Locked"

				if !@bar_user.save
					raise "error"
				end
			else
				respond_to do |format|
    				format.html  
    				format.json { render :json => "User is already locked" }
  				end	
			end
		end

	end

	def unbar_user
		@unbar_user = User.find(params[:unbar_user_id])
		@unbar_user.current_status  = "Active"

		if !@unbar_user.save
			raise "error"
		end
	end
end
