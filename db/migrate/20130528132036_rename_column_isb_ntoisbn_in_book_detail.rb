class RenameColumnIsbNtoisbnInBookDetail < ActiveRecord::Migration
  def up
  	rename_column :book_details, :ISBN, :isbn
  end

  def down
  	rename_column :book_details, :isbn, :ISBN
  end
end
