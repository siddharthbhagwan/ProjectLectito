# Application Controller
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!, except: [:search_books, :search_books_city, :search, :autocomplete_book_name, :autocomplete_author]
  before_action :user_barred?, except: [:barred, :destroy, :search, :sub_search]
  before_action :otp_verified?, except: [:otp_verification, :otp]
  # Online makes its own update as it is
  after_action :update_timestamp, except: [:online]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  def user_barred?
    if user_signed_in?
      unless current_user.profile.nil?
        if current_user.current_status == 'Locked'
          redirect_to profile_barred_path
          flash[:alert] = ' Account Locked '
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
    if !current_user.otp_verification
      redirect_to profile_verification_path
    end
  end
  
end
