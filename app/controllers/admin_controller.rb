class AdminController < ApplicationController
	authorize_resource :class => false

	def admin_view
		@user = User.order("id").page(params[:page]).per(5)
	end

	def edit
		@profile = Profile.all
	end

	def admin_user_details
		@user = User.find(params[:user_id])
	end

end
