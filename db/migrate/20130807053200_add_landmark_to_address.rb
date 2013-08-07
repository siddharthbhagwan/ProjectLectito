class AddLandmarkToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :landmark, :string
  end
end
