class AddNewNumberToProfile < ActiveRecord::Migration
  def up
    add_column :profiles, :old_phone_no, :integer
  end

  def down
    remove_column :profiles, :old_phone_no
  end
end
