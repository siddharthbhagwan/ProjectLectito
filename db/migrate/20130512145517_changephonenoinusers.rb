class Changephonenoinusers < ActiveRecord::Migration
  def up
  	change_column :profiles, :user_phone_no, :string
  end

  def down
  end
end
