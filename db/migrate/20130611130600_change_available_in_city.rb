class ChangeAvailableInCity < ActiveRecord::Migration
  def up
  	remove_column :user_books, :available_in_city
  	add_column :user_books, :available_in_city, :integer
  end

  def down
  	remove_column :user_books, :available_in_city
  	add_column :user_books, :available_in_city, :string
  end
end
