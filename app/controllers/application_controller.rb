class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!#, :except => [:search, :sub_search]
  #before_filter :is_user_barred, :except => [:user_barred, :destroy]

  rescue_from CanCan::AccessDenied do |exception|
  	redirect_to root_path, :alert => exception.message
  end

  def is_user_barred
    Rails.logger.debug "asdasdsadas " + current_user.profile.current_status
  	if user_signed_in?
      if current_user.profile.current_status == "b"
  		  redirect_to home_page_barred_path	
      end
  	end
  end
end
