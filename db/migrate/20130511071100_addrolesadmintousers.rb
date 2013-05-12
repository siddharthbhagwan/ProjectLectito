class Addrolesadmintousers < ActiveRecord::Migration
  def up
  	add_column :users, :roles_mask, :integer, :default=> '4', :null => :false
  end

  def down
  end
end
