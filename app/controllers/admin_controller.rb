class AdminController < ApplicationController
	authorize_resource :class => false

	def admin_view
		@profile = Profile.all
	end

	def edit
		@profile = Profile.all
	end

	def admin_index
	end
end
