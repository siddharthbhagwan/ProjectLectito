# Application Helper
module ApplicationHelper
  def check_admin!
    current_user.check_admin
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def chatbox
    user_accepted_transactions =  Transaction.where('((borrower_id = ? OR lender_id = ? ) AND (status != ? AND status != ? AND status != ? AND status != ?))', current_user.id , current_user.id, 'Pending', 'Cancelled', 'Rejected', 'Complete')
    @current_transactions = []
    user_accepted_transactions.each do |t|
      if !(User.where(id: t.borrower_id).take.is_delivery) || !(User.where(id: t.lender_id).take.is_delivery)
        @current_transactions << t
      end
    end
  end
end
