class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!#, :except => [:search, :sub_search]
  before_filter :is_user_barred, :except => [:barred, :destroy]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def is_user_barred
    if user_signed_in? 
      if current_user.current_status == "Locked"
         redirect_to profile_barred_path
      end
    end
  end
end
