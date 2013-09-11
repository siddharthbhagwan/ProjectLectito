class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!#, :except => [:search, :sub_search]
  before_action :is_user_barred, :except => [:barred, :destroy]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def is_user_barred
    if user_signed_in? 
      if !current_user.profile.nil?
        if current_user.current_status == "Locked"
           redirect_to profile_barred_path
           flash[:alert] = " Account Locked "
        end
      end
    end
  end
end
