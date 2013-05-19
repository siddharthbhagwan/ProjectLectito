class Changeuseridtypeinaddress < ActiveRecord::Migration
def up
	remove_column :addresses, :user_id
	add_column :addresses, :user_id, :integer
end

  def down
  end
end
