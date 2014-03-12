class AddResponeCodeToUser < ActiveRecord::Migration
  def up
    add_column :users, :response_code, :string
  end

  def down
    remove_column :users, :response_code
  end
end
