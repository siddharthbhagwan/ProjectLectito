class RenameColumnsInProfiles < ActiveRecord::Migration
  def up
  	rename_column :profiles, :First_Name, :user_first_name
  	rename_column :profiles, :Last_Name, :user_last_name
  	add_column :profiles, :user_phone_no ,:integer
  	add_column :profiles, :current_status, :string
  	add_column :profiles,  :last_update, :datetime
  end

  def down
  	rename_column :profiles, :user_first_name, :First_Name
  	rename_column :profiles, :user_first_name, :Last_Name
  	remove_column :profiles, :user_phone_no
  	remove_column :profiles, :current_status
  	remove_column :profiles, :last_update
  end
end
