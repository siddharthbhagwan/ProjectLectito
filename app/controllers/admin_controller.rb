class AdminController < ApplicationController
	def view
		@profile = Profile.all
	end

	def edit
		@profile = Profile.all
	end

	def permissions
	end
end
