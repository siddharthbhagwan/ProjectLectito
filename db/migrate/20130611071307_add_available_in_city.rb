class AddAvailableInCity < ActiveRecord::Migration
  def up
  	add_column :user_books, :available_in_city, :string
  end

  def down
  	remove_column :user_books, :available_in_city
  end
end
