class AddLastSeenAtToProfiles < ActiveRecord::Migration
  def up
    add_column :profiles, :last_seen_at, :datetime
  end

  def down
    remove_column :profiles, :last_seen_at
  end
end
