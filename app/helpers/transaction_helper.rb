module TransactionHelper

  # Fn that takes a transaction id and returns true or false depending on wether the current suer is a part of that transaction or not
	def is_my_transaction(trans_id)
    transaction =  Transaction.find(trans_id)
    if (transaction.lender_id == current_user.id) or (transaction.borrower_id == current_user.id)
      return true
    else
    	return false
    end

  rescue ActiveRecord::RecordNotFound
		return false
  end
end
