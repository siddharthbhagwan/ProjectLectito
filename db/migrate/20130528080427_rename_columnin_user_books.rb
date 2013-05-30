class RenameColumninUserBooks < ActiveRecord::Migration
  def up
  	rename_column :user_books, :book_details, :book_detail_id
  end

  def down
  end
end
