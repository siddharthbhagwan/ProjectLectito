class RenameBookDetailIdToBookId < ActiveRecord::Migration
  def up
  	rename_column :inventories, :book_detail_id, :book_id
  end

  def down
  	rename_column :inventories, :book_id, :book_detail_id
  end
end
