class AddOtpSent < ActiveRecord::Migration
  def up
    add_column :users, :otp_sent, :datetime
  end

  def down
    remove_column :users, :otp_sent
  end
end
