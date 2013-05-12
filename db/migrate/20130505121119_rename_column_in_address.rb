class RenameColumnInAddress < ActiveRecord::Migration
  def self.up
  	rename_column :addresses, :Uid, :user_id
  end

  def down
  	rename_column :addresses, :user_id, :Uid
  end
end
