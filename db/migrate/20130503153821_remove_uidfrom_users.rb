class RemoveUidfromUsers < ActiveRecord::Migration
  def up
  	remove_column :users, :uid
  end

  def down
  end
end
	