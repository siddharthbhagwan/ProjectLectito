class Removeadminfromusers < ActiveRecord::Migration
  def up
  	remove_column :users, :admin
  	remove_column :users, :roles_mask
  end

  def down
  end
end
