class ChatController < ApplicationController
  include ApplicationHelper

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
  	chatbox()
  end
end  