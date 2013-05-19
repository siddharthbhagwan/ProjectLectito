class RenameaddressLine4tolocalityinaddress < ActiveRecord::Migration
  def up
  	rename_column :addresses, :address_line4, :locality
  end

  def down
  	rename_column :addresses, :locality, :address_line4
  end
end
