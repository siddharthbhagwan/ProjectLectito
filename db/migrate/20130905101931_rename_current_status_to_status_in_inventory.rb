class RenameCurrentStatusToStatusInInventory < ActiveRecord::Migration
  def change
  	rename_column :inventories, :current_status, :status
  end
end
