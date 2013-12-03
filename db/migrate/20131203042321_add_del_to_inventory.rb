class AddDelToInventory < ActiveRecord::Migration
  def up
    add_column :inventories, :deleted, :boolean, :default => :false
  end

  def down
    remove_column :inventories, :deleted
  end
end
