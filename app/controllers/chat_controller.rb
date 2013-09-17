class ChatController < ApplicationController
  include ActionController::Live

  def show
    @transaction = Transaction.where(:id => params[:id]).take
    chat = Chat.where(:transaction_id => params[:id]).last(5)
    @history = Array.new
    chat.each do |c|
      @history << c.body
    end
    @history.join()
  end

  def new
    # chat = Chat.new
    # chat.transaction_id = params[:ref]
    # chat.body = params[:chat]
    # chat.from_user = current_user.id
    # logger.debug "123123123123 A"
    # if chat.save
    #   transaction = Transaction.where(:id => params[:ref]).take
    #   logger.debug "123123123123 B"
    #   if current_user.id == transaction.lender_id
    #     logger.debug "123123123123 C"
    #     publish_from_channel = "transaction_listener_" + transaction.lender_id.to_s
    #     publish_to_channel = "transaction_listener_" + transaction.borrower_id.to_s
    #   else
    #     logger.debug "123123123123 D"
    #     publish_from_channel = "transaction_listener_" + transaction.borrower_id.to_s
    #     publish_to_channel = "transaction_listener_" + transaction.lender_id.to_s
    #   end

    #   chat_data = Array.new
    #   chat_data << "chat"
    #   chat_data << {
    #     :text => params[:chat]
    #   }

    #   $redis.publish(publish_from_channel, chat_data.to_json)
    #   $redis.publish(publish_to_channel, chat_data.to_json)
    # else
    #   raise 'error'
    # end
  end

  def index
  	user_accepted_transactions =  Transaction.where("((borrower_id = ? OR lender_id = ? ) AND status = ? )", current_user.id , current_user.id, "Accepted")
    @current_transactions = Array.new
  	user_accepted_transactions.each do |t|
  		if !(User.where(:id => t.borrower_id).take.is_delivery) || !(User.where(:id => t.lender_id).take.is_delivery)
  			@current_transactions << t
  	  end
    end
  end
end  