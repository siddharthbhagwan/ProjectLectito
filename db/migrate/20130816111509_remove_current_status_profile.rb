class RemoveCurrentStatusProfile < ActiveRecord::Migration
  def up
  	remove_column :profiles, :current_status
  end

  def down
  	add_column :profiles, :current_status, :string
  end
end
