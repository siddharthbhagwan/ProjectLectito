class RenameColumnInProfile < ActiveRecord::Migration
  def up
  	rename_column :profiles, :Uid, :user_id
  end

  def down
  	rename_column :profiles, :user_id, :Uid
  end
end
