# Profile Controller
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
    @profile.delivery = 'true'
    if @profile.save
      flash[:notice] = 'Your Profile has been created'
      redirect_to new_address_path
    else
      redirect_to new_profile_path
    end
  end

  def update
    @profile = Profile.where(user_id: current_user.id).take
    if @profile.update_attributes(params[:profile])
      redirect_to edit_profile_path
      flash[:notice] = 'Your Profile has been updated'
     else
      render 'edit'
    end
  end

  def edit
    @profile = Profile.where(id: params[:id]).take
    chatbox
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
    p 'Updating ' + User.find(current_user.id).full_name.upcase + ' to ' + time_now.to_time.to_s
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
            # p 'Last seen ' + User.find(at.borrower_id).full_name + ' at ' + lsa.to_time.to_s
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
            # p 'Last seen ' + User.find(at.lender_id).full_name + ' at ' + lsa.to_time.to_s
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
          # p 'Last seen ' + User.find(ct.borrower_id).full_name + ' at ' + lsa.to_time.to_s
          # p 'Time now is  ' + time_now_update.to_s
          # p ' Difference is 3 ' + (time_now_update - lsa).seconds.to_s
          if !lsa.nil? && (time_now_update - lsa).seconds < 6
            active_trans_ids.push(ct.id)
          end
        else
          # current user is the borrower
          lsa = User.find(ct.lender_id).profile.last_seen_at.to_time
          # p 'Last seen ' + User.find(ct.lender_id).full_name + ' at ' + lsa.to_time.to_s
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
