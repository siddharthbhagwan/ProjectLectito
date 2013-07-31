class RemoveAddressLineFromAddress < ActiveRecord::Migration
  def up
  	remove_column :addresses, :address_line2
  	remove_column :addresses, :address_line3
  end

  def down
  	add_column :addresses, :address_line2, :string
  	add_column :addresses, :address_line3, :string
  end
end
