class ChatController < ApplicationController
  include ApplicationHelper
  before_action :otp_verified?

  def show
    @transaction = Transaction.where(id: params[:id]).take
    @book = Book.where(id: Inventory.where(id: @transaction.inventory_id).take.book_id).take.book_name
    if current_user.id == @transaction.lender_id
      @lender_borrower = User.find(@transaction.borrower_id).full_name
      @you = User.find(@transaction.lender_id).profile.chat_name
    else
      @lender_borrower = User.find(@transaction.lender_id).full_name
      @you =  User.find(@transaction.borrower_id).profile.chat_name
    end

    last_10_chats = Chat.where(transaction_id: params[:id]).last(10)
    @chat_history = String.new
    last_10_chats.each do |l|
      @chat_history << User.find(l.from_user).profile.chat_name + " : " + l.body[0..-3] + "\n"
    end
  end

  def box_chat_history
    @transaction = Transaction.where(id: params[:trid]).take
    if current_user.id == @transaction.lender_id
      @lender_borrower = User.find(@transaction.borrower_id).profile.chat_name
      @you = User.find(@transaction.lender_id).profile.chat_name
    else
      @lender_borrower = User.find(@transaction.lender_id).profile.chat_name
      @you =  User.find(@transaction.borrower_id).profile.chat_name
    end

    if params[:id].blank?
      last_5_chats = Chat.where(transaction_id: params[:trid]).last(5)
    else
      last_5_chats = Chat.where(transaction_id: params[:trid]).where('id < ?', params[:id]).order(id: :desc).limit(5).reverse
    end

    chat_history = Array.new
    last_5_chats.each do |l|
      chat_history << User.find(l.from_user).profile.chat_name
      chat_history << l.body
      chat_history << l.id
    end

    respond_to do |format|
        format.json { render json: chat_history.to_json }
    end
  end
  
  def index
  	chatbox()
  end
end  