class RenameBorrowerCommentsinTransactions < ActiveRecord::Migration
  def change
  	rename_column :transactions, :borrowe_comments, :borrower_comments
  end
end
