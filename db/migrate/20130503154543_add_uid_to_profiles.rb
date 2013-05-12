class AddUidToProfiles < ActiveRecord::Migration
  def change
  	add_column :profiles, :Uid, :integer
  end
end
