class RenameColumnInBookDetails < ActiveRecord::Migration
  def up
  	rename_column :user_books, :book_id, :book_details
  end

  def down
  	rename_column :user_books, :book_details, :book_id
  end
end
