class Moduserbooks < ActiveRecord::Migration
  def up
  	remove_column :user_books, :available_in_city
  	add_column :user_books, :available_in_city, :string
  end

  def down
  end
end
