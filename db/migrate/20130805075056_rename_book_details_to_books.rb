class RenameBookDetailsToBooks < ActiveRecord::Migration
  def up
  	rename_table :book_details, :books
  end

  def down
  	rename_table :books, :book_details
  end
end
