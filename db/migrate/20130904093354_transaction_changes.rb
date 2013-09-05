class TransactionChanges < ActiveRecord::Migration
  def up
  	change_column :transactions, :return_pickup_date, :string
  	rename_column :transactions, :feedback, :lender_feedback
  	rename_column :transactions, :comments, :lender_comments
  	add_column :transactions, :borrower_feedback, :string
  	add_column :transactions, :borrowe_comments, :string
  end

  def down
  	change_column :transactions, :return_pickup_date, :datetime
  	rename_column :transactions, :lender_feedback, :feedback
  	rename_column :transactions, :lender_comments, :comments
  	remove_column :transactions, :borrower_feedback
  	remove_column :transactions, :borrowe_comments
  end
end
