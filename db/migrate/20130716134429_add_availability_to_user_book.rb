class AddAvailabilityToUserBook < ActiveRecord::Migration
  def change
    add_column :user_books, :availability, :string
  end
end
