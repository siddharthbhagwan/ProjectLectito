class AdminController < ApplicationController
	class Error < RuntimeError; end

	load_and_authorize_resource :class => User

	def index
		@user = User.all
	end

	def edit
		@profile = Profile.all
	end

	def user_details
		@user = User.find(params[:user_id])

		if !@user.profile.nil? and @user.profile.current_status == "Locked"
			@locked = true
		end
	end

	def bar_user
		@bar_user = User.find(params[:bar_user_id])

		if current_user.id == params[:bar_user_id].to_i
			@bar_user.errors[:base]<< "Admin cannot block itself"
			@bar_user.save
		else
			if @bar_user.profile.current_status != "Locked"
				@bar_user.profile.current_status  = "Locked"

				if !@bar_user.profile.save
					raise "error"
				end
			else
				@bar_user.profile.errors[:base]<< "User already Locked"
				@bar_user.save	
			end
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @bar_user.errors.full_messages.to_json }
  		end
	end

	def unbar_user
		@unbar_user = User.find(params[:unbar_user_id])
		@unbar_user.profile.current_status  = "Active"

		if !@unbar_user.profile.save
			raise "error"
		end
	end
end
