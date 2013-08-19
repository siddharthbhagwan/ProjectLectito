class AddStatusToUser < ActiveRecord::Migration
  def change
  	add_column :users, :current_status, :string
  end
end
