class ChangerolesMaskinusers < ActiveRecord::Migration
  def up
  	remove_column :users, :roles_mask
  	add_column :users, :roles_mask, :integer, :default => 4 , :null => false
  end

  def down
  end
end
