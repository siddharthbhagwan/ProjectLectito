# Profile Controller
require 'net/http'
class ProfileController < ApplicationController
  include ApplicationHelper
  load_and_authorize_resource class: Profile

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
    @profile.profile_status = 'Online'
    @profile.delivery = 'false'
    @profile.otp_failed_attempts = 0
    if @profile.save
      redirect_to profile_verification_path
      # flash[:notice] = 'Your Profile has been created'
      # redirect_to new_address_path
    else
      redirect_to new_profile_path
    end
  end

  def update
    old_number = Profile.where(user_id: current_user.id).take.user_phone_no
    @profile = Profile.where(user_id: current_user.id).take
    if @profile.update_attributes(params[:profile])
      if old_number == @profile.user_phone_no
        redirect_to edit_profile_path
        flash[:notice] = 'Your Profile has been updated'
      else
        user = User.find(current_user.id)
        user.otp_verification = false
        user.save
        redirect_to profile_verification_path(number: old_number)
      end
     else
      render 'edit'
    end
  end

  def edit
    @profile = Profile.where(id: params[:id]).take
    chatbox
  end

  def otp
    # Not verfied, send SMS
    if !User.find(current_user.id).otp_verification
      user = User.find(current_user.id)
      @mobile_number  = user.profile.user_phone_no
      otp_failed_attempts = user.otp_failed_attempts

      if user.otp_failed_timestamp == nil
        time_lapse = 2
      else
        time_lapse = (DateTime.now - user.otp_failed_timestamp.to_datetime).to_i
      end

      if (( time_lapse > 0 ) || !(0..2).include?(otp_failed_attempts))
        require 'net/http'
        verification_code = rand(100000..999999) 
        current_user.otp = verification_code
        if current_user.save!
          message = ' Your Verification Code for Project Lectito is ' + verification_code.to_s
          mobile_number = Profile.where(user_id: current_user.id).take.user_phone_no
          msg91_url = ENV['msg91_url'] + '&mobiles=' + mobile_number + '&message=' + message + '&sender=LECTIT' + '&route=4&response=json'
          encoded_url = URI.encode(msg91_url)
          uri = URI.parse(encoded_url)
          msg91_url_reponse = Net::HTTP.get(uri)
          parsed_response = JSON.parse(msg91_url_reponse)
          
          user = User.find(current_user.id)
          user.response_code = parsed_response['message']
          user.otp_verification = false
          user.otp_failed_attempts = 0
          user.save!
        end
      end
    else
      # Verified, no need of any action
      redirect_to '/inventory/search'
    end
  end

  def otp_verification
    user = User.find(current_user.id)
    otp_failed_attempts = user.otp_failed_attempts

    # Verification code matches
    if params[:verification_code].to_i == user.otp
      user.otp_verification = true
      user.otp_failed_attempts = 0
      user.save
      redirect_to edit_profile_path(current_user.profile.id)
      flash[:notice] = 'Your Profile has been updated '
    else

      # Verification code doesn't match
      # Number of attempts < 3
      if (0..2).include?(otp_failed_attempts)
        user.otp_failed_attempts = user.otp_failed_attempts + 1
        user.otp_failed_timestamp = DateTime.now
        user.save
        redirect_to profile_verification_path(current_user.profile.id, number: params[:number])
        flash[:notice] = 'Invalid Code. Failed attemptss - ' + user.otp_failed_attempts.to_s
      else

        # Number of attempts > 3
        time_lapse = (DateTime.now - user.otp_failed_timestamp.to_datetime).to_i

        # Last attempt was more than a day before
        if time_lapse > 0
          user.otp_failed_attempts = user.otp_failed_attempts = 1
          user.otp_failed_timestamp = DateTime.now
          user.save
          redirect_to edit_profile_path(current_user.profile.id, number: params[:number])
          flash[:notice] = 'Invalid Code. Failed attempts - ' + user.otp_failed_attempts.to_s
        else

          # Last attempt was less than a day before
          profile = user.profile
          profile.user_phone_no = params[:number].to_i
          profile.save
          redirect_to edit_profile_path(current_user.profile.id)
          flash[:notice] = 'Your Phone Number Could Not be Updated. Please try again after 24 hours '
        end
      end
    end
  end

  def rating
    @name = User.find(current_user.id).full_name

    @good_lender = Transaction.where(lender_id: current_user.id, borrower_feedback: :good).count
    @good_borrower = Transaction.where(borrower_id: current_user.id, lender_feedback: :good).count
    @good = @good_borrower + @good_lender

    @bad_lender = Transaction.where(lender_id: current_user.id, borrower_feedback: :bad).count
    @bad_borrower = Transaction.where(borrower_id: current_user.id, lender_feedback: :bad).count
    @bad = @bad_lender + @bad_borrower

    @neutral_lender = Transaction.where(lender_id: current_user.id, borrower_feedback: :neutral).count
    @neutral_borrower = Transaction.where(borrower_id: current_user.id, lender_feedback: :neutral).count
    @neutral = @neutral_lender + @neutral_borrower

    @total_books = Inventory.where(user_id: current_user.id, deleted: :false).count
    @transactions = Transaction.where('(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)', current_user.id, current_user.id, 'Rejected', 'Cancelled').order('created_at desc')

    @total_transactions = @transactions.count
    @comment_history = []

    @transactions.each do |t|
      if t.lender_id == current_user.id
        if t.borrower_comments != '' && !t.borrower_comments.nil?
          @comment_history.push(t.borrower_comments + ' ~ ' + User.find(t.borrower_id).full_name)
        end
      else
        if t.lender_comments != '' && !t.lender_comments.nil?
          @comment_history.push(t.lender_comments + ' ~ ' + User.find(t.lender_id).full_name)
        end
      end
    end
  end

  def public_rating
    pr = Transaction.find(params[:tr_id])
    id = current_user.id

    if pr.lender_id == id
      @name = User.find(pr.borrower_id).full_name

      @good_lender = Transaction.where(lender_id: pr.borrower_id, borrower_feedback: :good).count
      @good_borrower = Transaction.where(borrower_id: pr.borrower_id, lender_feedback: :good).count
      @good = @good_borrower + @good_lender

      @bad_lender = Transaction.where(lender_id: pr.borrower_id, borrower_feedback: :bad).count
      @bad_borrower = Transaction.where(borrower_id: pr.borrower_id, lender_feedback: :bad).count
      @bad = @bad_lender + @bad_borrower


      @neutral_lender = Transaction.where(lender_id: pr.borrower_id, borrower_feedback: :neutral).count
      @neutral_borrower = Transaction.where(borrower_id: pr.borrower_id, lender_feedback: :neutral).count
      @neutral = @neutral_lender + @neutral_borrower

      @total_books = Inventory.where(user_id: pr.borrower_id, deleted: :false).count
      @transactions = Transaction.where('(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)', pr.borrower_id, pr.borrower_id, 'Rejected', 'Cancelled').order('created_at desc')

      @total_transactions = @transactions.count
      @comment_history = []

      @transactions.each do |t|
        if t.lender_id == pr.borrower_id
          if t.borrower_comments != '' && !t.borrower_comments.nil?
            @comment_history.push(t.borrower_comments + ' ~ ' + User.find(t.borrower_id).full_name)
          end
        else
          if t.lender_comments != '' && !t.lender_comments.nil?
            @comment_history.push(t.lender_comments + ' ~ ' + User.find(t.lender_id).full_name)
          end
        end
      end

      respond_to do |format|
        format.html { render :rating }
        format.json {
          json_profile = Array.new
          json_profile << {
            name: @name,
            good: @good,
            neutral: @neutral,
            bad: @bad,
            transactions: @total_transactions,
            books: @total_books
          }
          render json: json_profile.to_json }
      end

    elsif  pr.borrower_id == current_user.id
      @name = User.find(pr.lender_id).full_name

      @good_lender = Transaction.where(lender_id: pr.lender_id, borrower_feedback: :good).count
      @good_borrower = Transaction.where(borrower_id: pr.lender_id, lender_feedback: :good).count
      @good = @good_borrower + @good_lender

      @bad_lender = Transaction.where(lender_id: pr.lender_id, borrower_feedback: :bad).count
      @bad_borrower = Transaction.where(borrower_id: pr.lender_id, lender_feedback: :bad).count
      @bad = @bad_lender + @bad_borrower

      @neutral_lender = Transaction.where(lender_id: pr.lender_id, borrower_feedback: :neutral).count
      @neutral_borrower = Transaction.where(borrower_id: pr.lender_id, lender_feedback: :neutral).count
      @neutral = @neutral_lender + @neutral_borrower

      @total_books = Inventory.where(user_id: pr.lender_id, deleted: :false).count
      @transactions = Transaction.where('(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)', pr.lender_id, pr.lender_id, 'Rejected', 'Cancelled').order('created_at desc')

      @total_transactions = @transactions.count

      @comment_history = []

      @transactions.each do |t|
        if t.lender_id == pr.lender_id
          if t.borrower_comments != '' && !t.borrower_comments.nil?
            @comment_history.push(t.borrower_comments + ' ~ ' + User.find(t.borrower_id).full_name)
          end
        else
          if t.lender_comments != '' && !t.lender_comments.nil?
            @comment_history.push(t.lender_comments + ' ~ ' + User.find(t.lender_id).full_name)
          end
        end
      end

      respond_to do |format|
        format.html  { render :rating }
        format.json {
          json_profile = Array.new
          json_profile << {
            name: @name,
            good: @good,
            neutral: @neutral,
            bad: @bad,
            transactions: @total_transactions,
            books: @total_books
          }
          render json: json_profile.to_json }
      end

    else
      redirect_to home_path
      flash[:alert] = 'No such page exists!'
    end
  end

  def online
    # Called every n seconds to update timestamp
    online = User.find(current_user.id).profile
    time_now = DateTime.now
    online.last_seen_at = time_now
    # p 'Updating ' + User.find(current_user.id).full_name.upcase + ' to ' + time_now.to_time.to_s
    online.save

    # Array to store the id's whose online status needs to be visible to current user
    active_trans_ids = Array.new

    # For Transaction history, only completed transactions need to be listed
    # Fn returns id's (lender or borrower) , and not transaction ids. Thus duplication check greatly helps
    if params[:page] == '/transaction/history'
      all_transactions =  Transaction.where('((borrower_id = ? OR lender_id = ? ) AND status = ? )', current_user.id , current_user.id, 'Complete').order('request_date desc')
      all_transactions.each do |at|
        # if current user is the lender
        time_now_update = Time.now
        if at.lender_id == current_user.id
          # check for duplication
          if !active_trans_ids.include? at.borrower_id
            lsa = User.find(at.borrower_id).profile.last_seen_at
            # p 'Last seen ' + User.find(at.borrower_id).full_name + ' at ' + lsa.to_s
            # p 'Time now is  ' + time_now_update.to_s
            # p ' Difference is 1 ' + (time_now_update - lsa).seconds.to_s
            if !lsa.nil? && (time_now_update - lsa).seconds < 6.5
              active_trans_ids.push(at.borrower_id)
            end
          end
        else
          # current user is the borrower
          # check for duplication
          if !active_trans_ids.include? at.lender_id
            # p 'Last seen ' + User.find(at.lender_id).full_name + ' at ' + lsa.to_s
            # p 'Time now is  ' + time_now_update.now.to_s
            # p ' Difference is 2 ' + (time_now_update.now - lsa).seconds.to_s
            if !lsa.nil? && (Time.now - lsa).seconds < 6.5
              active_trans_ids.push(at.lender_id)
            end
          end
        end
      end
      # For home page / search page, transaction in progress need to be listed
      # Returns transaction ids. So need need for duplication checks
    else
      # puts ' Checking for ' + User.find(current_user.id).full_name + ' - ' + current_user.id.to_s
      #TODO Check if chatbox call is cheaper than the quesries themselves
      chatbox
      @current_transactions.each do |ct|
        # current user is the lender
        time_now_update = Time.now
        if ct.lender_id == current_user.id
          lsa = User.find(ct.borrower_id).profile.last_seen_at
          # p 'Last seen ' + User.find(ct.borrower_id).full_name + ' at ' + lsa.to_s
          # p 'Time now is  ' + time_now_update.to_s
          # p ' Difference is 3 ' + (time_now_update - lsa).seconds.to_s
          if !lsa.nil? && (time_now_update - lsa).seconds < 6
            active_trans_ids.push(ct.id)
          end
        else
          # current user is the borrower
          lsa = User.find(ct.lender_id).profile.last_seen_at.to_time
          # p 'Last seen ' + User.find(ct.lender_id).full_name + ' at ' + lsa.to_s
          # p 'Time now is  ' + time_now_update.to_s
          # p ' Difference is 4 ' + (time_now_update - lsa).seconds.to_s
          if !lsa.nil? && (time_now_update - lsa).seconds < 6.5
            active_trans_ids.push(ct.id)
          end
        end
      end
    end

    respond_to do |format|
      # p ' Sending list to caller ' + active_trans_ids.inspect
      format.json { render json: active_trans_ids.to_json }
    end
  end
end
