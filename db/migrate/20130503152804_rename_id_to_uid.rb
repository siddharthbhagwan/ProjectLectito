class RenameIdToUid < ActiveRecord::Migration
  def up
  	rename_column :users, :id, :uid
  end

  def down
  end
end
