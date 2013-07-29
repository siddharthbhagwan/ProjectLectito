class AdminController < ApplicationController
	load_and_authorize_resource :class => User

	def view
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
		if current_user.id == params[:bar_user_id].to_i
			raise "Admin cannot block itself"
		else
			@bar_user = User.find(params[:bar_user_id])

			if @bar_user.profile.current_status != "Locked"
				@bar_user.profile.current_status  = "Locked"

				if !@bar_user.profile.save
					raise "error"
				end
			else
				raise "User Already Blocked"	
			end
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
