class RenameUserInventoryIdtoInventoryId < ActiveRecord::Migration
  def up
  	rename_column :transactions, :user_inventory_id, :inventory_id
  end

  def down
  	rename_column :transactions, :inventory_id, :user_inventory_id
  end
end
