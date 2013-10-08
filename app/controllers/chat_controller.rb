class ChatController < ApplicationController
  include ActionController::Live

  def show
    @transaction = Transaction.where(:id => params[:id]).take
    @book = Book.where(:id => Inventory.where(:id => @transaction.inventory_id).take.book_id).take.book_name
    if current_user.id == @transaction.lender_id
      @lender_borrower = User.find(@transaction.borrower_id).full_name
      @you = User.find(@transaction.lender_id).profile.chat_name
    else
      @lender_borrower = User.find(@transaction.lender_id).full_name
      @you =  User.find(@transaction.borrower_id).profile.chat_name
    end

    chat = Chat.where(:transaction_id => params[:id]).last(5)
    @history = Array.new
    chat.each do |c|
      @history << c.body
    end
    @history.join()
  end

  def show_popup
    @transaction = Transaction.where(:id => params[:id]).take
    chat = Chat.where(:transaction_id => params[:id]).last(5)
    @history = Array.new
    chat.each do |c|
      @history << c.body
    end
    @history.join()
  end
  
  def index
  	user_accepted_transactions =  Transaction.where("((borrower_id = ? OR lender_id = ? ) AND status = ? )", current_user.id , current_user.id, "Accepted")
    @current_transactions = Array.new
    @current_transactions_id = Array.new
  	user_accepted_transactions.each do |t|
  		if !(User.where(:id => t.borrower_id).take.is_delivery) || !(User.where(:id => t.lender_id).take.is_delivery)
  			@current_transactions << t
        @current_transactions_id << t.id

        if current_user.id == t.lender_id
          @lender_borrower_name = User.find(t.borrower_id).full_name
        else
          @lender_borrower_name = User.find(t.lender_id).full_name
        end
  	  end
    end
  end
end  