module ApplicationHelper

	def check_admin!
		current_user.check_admin
	end
end
