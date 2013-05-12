class Changerolesmaskinusers < ActiveRecord::Migration
  def up
  	change_column :users, :roles_mask, :integer, :default => 4 , :null => false
  end

  def down
  end
end
