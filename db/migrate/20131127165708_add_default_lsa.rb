class AddDefaultLsa < ActiveRecord::Migration
  def change
    change_column :profiles, :last_seen_at, :datetime, :default => DateTime.now
  end
end
