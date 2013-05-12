class Cahngerolesmaskinusers < ActiveRecord::Migration
  def up
  	remove_column :users, :roles_mask
  	add_column :users, :roles_mask, :integer
  end

  def down
  end
end
