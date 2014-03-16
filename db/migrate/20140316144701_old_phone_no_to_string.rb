class OldPhoneNoToString < ActiveRecord::Migration
  def up
    change_column :profiles, :old_phone_no, :string
  end

  def down
    change_column :profiles, :old_phone_no, :integer
  end
end
