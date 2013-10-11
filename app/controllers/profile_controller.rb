class ProfileController < ApplicationController
  load_and_authorize_resource :class => Profile

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
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
    @transactions = Transaction.where("(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)", current_user.id, current_user.id, 'Rejected', 'Cancelled' )

    @total_transactions = @transactions.count 

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
      @transactions = Transaction.where("(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)", pr.borrower_id, pr.borrower_id, 'Rejected', 'Cancelled' )

      @total_transactions = @transactions.count

      @comment_history = @transactions.order("created_at desc").limit(5)

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
      @transactions = Transaction.where("(lender_id = ? OR borrower_id = ?) AND (status != ? OR status != ?)", pr.borrower_id, pr.borrower_id, 'Rejected', 'Cancelled' )

      @total_transactions = @transactions.count

      render :rating
    else
      redirect_to home_path
      flash[:alert] = "No such page exists!"
    end
  end
end