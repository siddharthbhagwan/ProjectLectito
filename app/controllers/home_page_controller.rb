class HomePageController < ApplicationController
	before_action :otp_verified?
	def home
	#	if !user_signed_in?
	#		redirect_to new_user_session_path
	#	end
	end

	def admin
		if !current_user.admin
			redirect_to home_path
		end
	end
end