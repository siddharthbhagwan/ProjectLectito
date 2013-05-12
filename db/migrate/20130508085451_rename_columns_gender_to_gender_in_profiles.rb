class RenameColumnsGenderToGenderInProfiles < ActiveRecord::Migration
  def up
  	rename_column :profiles, :Gender, :gender
  end

  def down
  	rename_column :profiles, :gender, :Gender
  end
end
