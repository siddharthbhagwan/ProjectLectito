class EditUserBooks < ActiveRecord::Migration
  def up
  	remove_column :user_books, :book_id
  	add_column :user_books, :user_id, :integer
  	add_column :user_books, :book_id, :integer
  end

  def down
  	add_column :user_books, :book_id, :integer
  	remove_column :user_books, :user_id, :integer
  	remove_column :user_books, :book_id, :integer
  end
end