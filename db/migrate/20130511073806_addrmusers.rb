class Addrmusers < ActiveRecord::Migration
  def up
  	add_column :users, :roles_mask, :integer
  end

  def down
  end
end
