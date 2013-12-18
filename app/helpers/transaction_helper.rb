module TransactionHelper
	def is_my_transaction(trans_id)
    transaction =  Transaction.find(trans_id)
    if (transaction.lender_id == current_user.id) or (transaction.borrower_id == current_user.id)
    	true
    else
    	false
    end

  rescue ActiveRecord::RecordNotFound
		return false
  end
end
