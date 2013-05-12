class AddprofileStatusToProfile < ActiveRecord::Migration
  def up
  	add_column :profiles, :profile_status, :string
  end

  def down
  end
end
