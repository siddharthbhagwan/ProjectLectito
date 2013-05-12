class RenameColnsInAddress < ActiveRecord::Migration
  def up
  	rename_column :addresses, :house_no, :address_line1
  	rename_column :addresses, :bldg, :address_line2
  	rename_column :addresses, :street, :address_line3
  	rename_column :addresses, :area, :address_line4
  end

  def down
  	rename_column :addresses, :address_line1, :house_no
  	rename_column :addresses, :address_line2, :bldg
  	rename_column :addresses, :address_line3, :street
  	rename_column :addresses, :address_line4, :area
  end
end
