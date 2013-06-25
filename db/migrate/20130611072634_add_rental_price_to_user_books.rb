class AddRentalPriceToUserBooks < ActiveRecord::Migration
  def change
    add_column :user_books, :rental_price, :integer
  end
end
