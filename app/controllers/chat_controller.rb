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

    last_10_chats = Chat.where(:transaction_id => params[:id]).last(10)
    @chat_history = String.new
    last_10_chats.each do |l|
      @chat_history << User.find(l.from_user).profile.chat_name + " : " + l.body
    end
    puts @chat_history.inspect
  end
  
  def index
  	chatbox()
  end
end  