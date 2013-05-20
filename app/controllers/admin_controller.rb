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
	end

end
