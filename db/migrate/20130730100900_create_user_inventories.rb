class CreateUserInventories < ActiveRecord::Migration
  def change
    create_table :user_inventories do |t|
      t.integer :user_id
      t.integer :book_detail_id
      t.float :rental_price
      t.integer :available_in_city
      t.string :current_status
      t.float :commission
      t.integer :no_of_borrows
      t.timestamp :upload_date
      t.string :condition_of_book
      t.boolean :book_deleted
      t.timestamp :deleted_date

      t.timestamps
    end
  end
end
