class AddFeedbackAndCommenttoTransaction < ActiveRecord::Migration
  def change
  	add_column :transactions, :feedback, :string
  	add_column :transactions, :comments, :string
  end
end
