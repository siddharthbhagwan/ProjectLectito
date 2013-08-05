class RenameUserInventoryToInventory < ActiveRecord::Migration
  def up
  	rename_table :user_inventories, :inventories
  end

  def down
  	rename_table :inventories, :user_inventories
  end
end
