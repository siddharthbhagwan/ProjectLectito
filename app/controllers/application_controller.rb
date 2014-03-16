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
    if user_signed_in?
      if params[:controller] != 'devise/sessions'
        if !current_user.otp_verification
          if current_user.profile.nil?
            redirect_to new_profile_path
          else
            # Verification had failed for a number change, more than a day before, Account lock removed
            if (( !current_user.profile.old_phone_no.nil? ) && (((DateTime.now - current_user.otp_failed_timestamp.to_datetime).to_i) > 0))
              current_user.otp_verification = true
              current_user.save
              redirect_to edit_profile_path(current_user.profile.id)
              flash[:alert] = 'You can try updating your phone number again '
            else 
              # Verification failed for new number, or verification failed for number change, less than a day before
              redirect_to profile_verification_path
              flash[:alert] = 'Please complete the verification to continue '
            end
          end
        end
      end
    end
  end
  
end
