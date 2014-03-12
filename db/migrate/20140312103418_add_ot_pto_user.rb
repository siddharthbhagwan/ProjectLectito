class AddOtPtoUser < ActiveRecord::Migration
  def up
    add_column :users, :otp, :integer
    add_column :users, :otp_failed_attempts, :integer
    add_column :users, :otp_verification, :boolean, default: :false
    add_column :users, :otp_failed_timestamp, :datetime
  end

  def down
    remove_column :users, :otp
    remove_column :users, :otp_failed_attempts
    remove_column :users, :otp_verification
    remove_column :users, :otp_failed_timestamp
  end
end
