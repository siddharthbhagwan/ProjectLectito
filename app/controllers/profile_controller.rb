class ProfileController < ApplicationController
  include ApplicationHelper
  Firebase.base_uri = "https://projectlectito.Firebaseio.com/"
  load_and_authorize_resource :class => Profile

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
    @profile.profile_status = "Online"
    if @profile.save
      flash[:notice] = "Your Profile has been created"
      redirect_to new_address_path
    end
  end

  def update
    @profile = Profile.where(:user_id => current_user.id).take
      if @profile.update_attributes(params[:profile])
         redirect_to edit_profile_path
         flash[:notice] = "Your Profile has been updated"
       else
        render 'edit'
      end
  end

  def edit
    @profile = Profile.where(:id => params[:id]).take
    chatbox()
  end

  def rating

    @name = User.find(current_user.id).full_name

    @good_lender = Transaction.where(:lender_id => current_user.id, :borrower_feedback => 'good').count
    @good_borrower = Transaction.where(:borrower_id => params[:id], :lender_feedback => 'good').count
    @good = @good_borrower + @good_lender

    @bad_lender = Transaction.where(:lender_id => current_user.id, :borrower_feedback => 'bad').count
    @bad_borrower = Transaction.where(:borrower_id => current_user.id, :lender_feedback => 'bad').count 
    @bad = @bad_lender + @bad_borrower

    @neutral_lender = Transaction.where(:lender_id => current_user.id, :borrower_feedback => 'neutral').count
    @neutral_borrower = Transaction.where(:borrower_id => current_user.id, :lender_feedback => 'neutral').count
    @neutral = @neutral_lender + @neutral_borrower

    @total_books = Inventory.where(:user_id => current_user.id).count
    @transactions = Transaction.where("(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)", current_user.id, current_user.id, 'Rejected', 'Cancelled' ).order("created_at desc")

    @total_transactions = @transactions.count
    @comment_history = []

    @transactions.each do |t|
      if t.lender_id == current_user.id
        if t.borrower_comments != "" and !t.borrower_comments.nil?
          @comment_history.push(t.borrower_comments + " ~ " + User.find(t.borrower_id).full_name)
        end
      else
        if t.lender_comments != "" and !t.lender_comments.nil?
          @comment_history.push(t.lender_comments + " ~ " + User.find(t.lender_id).full_name)
        end
      end
    end

  end

  def public_rating
    pr = Transaction.find(params[:tr_id])
    id = current_user.id

    if pr.lender_id == current_user.id   

      @name = User.find(pr.borrower_id).full_name

      @good_lender = Transaction.where(:lender_id => pr.borrower_id, :borrower_feedback => 'good').count
      @good_borrower = Transaction.where(:borrower_id => pr.borrower_id, :lender_feedback => 'good').count
      @good = @good_borrower + @good_lender

      @bad_lender = Transaction.where(:lender_id => pr.borrower_id, :borrower_feedback => 'bad').count
      @bad_borrower = Transaction.where(:borrower_id => pr.borrower_id, :lender_feedback => 'bad').count 
      @bad = @bad_lender + @bad_borrower

      @neutral_lender = Transaction.where(:lender_id => pr.borrower_id, :borrower_feedback => 'neutral').count
      @neutral_borrower = Transaction.where(:borrower_id => pr.borrower_id, :lender_feedback => 'neutral').count
      @neutral = @neutral_lender + @neutral_borrower

      @total_books = Inventory.where(:user_id => pr.borrower_id).count
      @transactions = Transaction.where("(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)", pr.borrower_id, pr.borrower_id, 'Rejected', 'Cancelled' ).order("created_at desc")

      @total_transactions = @transactions.count
      @comment_history = []

      @transactions.each do |t|
        if t.lender_id == pr.borrower_id
          if t.borrower_comments != "" and !t.borrower_comments.nil?
            @comment_history.push(t.borrower_comments + " ~ " + User.find(t.borrower_id).full_name)
          end
        else
          if t.lender_comments != "" and !t.lender_comments.nil?
            @comment_history.push(t.lender_comments + " ~ " + User.find(t.lender_id).full_name)
          end
        end
      end

      render :rating
    elsif  pr.borrower_id == current_user.id

      @name = User.find(pr.lender_id).full_name

      @good_lender = Transaction.where(:lender_id => pr.lender_id, :borrower_feedback => 'good').count
      @good_borrower = Transaction.where(:borrower_id => pr.lender_id, :lender_feedback => 'good').count 
      @good = @good_borrower + @good_lender

      @bad_lender = Transaction.where(:lender_id => pr.lender_id, :borrower_feedback => 'bad').count
      @bad_borrower = Transaction.where(:borrower_id => pr.lender_id, :lender_feedback => 'bad').count 
      @bad = @bad_lender + @bad_borrower

      @neutral_lender = Transaction.where(:lender_id => pr.lender_id, :borrower_feedback => 'neutral').count
      @neutral_borrower = Transaction.where(:borrower_id => pr.lender_id, :lender_feedback => 'neutral').count
      @neutral = @neutral_lender + @neutral_borrower

      @total_books = Inventory.where(:user_id => pr.borrower_id).count
      @transactions = Transaction.where("(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)", pr.borrower_id, pr.borrower_id, 'Rejected', 'Cancelled' ).order("created_at desc")

      @total_transactions = @transactions.count

      @comment_history = []

      @transactions.each do |t|
        if t.lender_id == pr.lender_id
          if t.borrower_comments != "" and !t.borrower_comments.nil?
            @comment_history.push(t.borrower_comments + " ~ " + User.find(t.borrower_id).full_name)
          end
        else
          if t.lender_comments != "" and !t.lender_comments.nil?
            @comment_history.push(t.lender_comments + " ~ " + User.find(t.lender_id).full_name)
          end
        end
      end

      render :rating
    else
      redirect_to home_path
      flash[:alert] = "No such page exists!"
    end
  end

  def update_profile_status
    profile = Profile.where(:user_id => current_user.id).take
    if profile.profile_status == "Online"
      respond_to do |format|
        format.html  
        format.json { render :json => "Online" }
      end 
    else
      profile.profile_status = "Online"
      my_transactions_as_lender = Transaction.where(:lender_id => current_user.id).where.not(:status => "Rejected").where.not(:status => "Cancelled").where.not(:status => "Complete")
      my_transactions_as_borrower = Transaction.where(:borrower_id => current_user.id).where.not(:status => "Rejected").where.not(:status => "Cancelled").where.not(:status => "Complete")

      if !my_transactions_as_lender.nil?
        my_transactions_as_lender.each do |tl|
          update_lender_offline = Array.new
          update_lender_offline << "online"
          update_lender_offline << {
          :id => tl.id
          }
          publish_channel_all_borrowers = "transaction_listener_" + tl.borrower_id.to_s
          Firebase.push(publish_channel_all_borrowers, update_lender_offline.to_json)
        end
      end

      if !my_transactions_as_borrower.nil?
        my_transactions_as_borrower.each do |tl|
          update_borrower_offline = Array.new
          update_borrower_offline << "online"
          update_borrower_offline << {
          :id => tl.id
          }
          publish_channel_all_lenders = "transaction_listener_" + tl.lender_id.to_s
          Firebase.push(publish_channel_all_lenders, update_borrower_offline.to_json)
        end
      end

      if profile.save
        respond_to do |format|
          format.html  
          format.json { render :json => "Offline" }
        end
      end
    end
  end
end