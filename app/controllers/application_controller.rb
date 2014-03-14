# Application Controller
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!, except: [:search_books, :search_books_city, :search, :autocomplete_book_name, :autocomplete_author]
  before_action :user_barred?, except: [:barred, :destroy, :search, :sub_search]
  # Online makes its own update as it is
  after_action :update_timestamp, except: [:online]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  def user_barred?
    if user_signed_in?
      unless params[:controller] == 'devise/sessions'
        unless current_user.profile.nil?
          if current_user.current_status == 'Locked'
            redirect_to profile_barred_path
            flash[:alert] = ' Account Locked '
          end
        end
      end
    end
  end

  def update_timestamp
    if user_signed_in?
      online = User.find(current_user.id).profile
      unless online.blank?
        online.last_seen_at = DateTime.now.to_time
        online.save
      end  
    end
  end

  def otp_verified?
    p 'CALLED CHECK'
    if user_signed_in?
      p 'CALLED CHECK 5'
      if params[:controller] != 'devise/sessions'
        p 'CALLED CHECK 2'
        if !current_user.otp_verification
          p 'CALLED CHECK 3'
          if current_user.profile.nil?
            p 'CALLED CHECK 4'
            redirect_to new_profile_path
          else
            redirect_to profile_verification_path
            flash[:alert] = 'Please complete the verification to continue '
          end
        end
      end
    end
  end
  
end
