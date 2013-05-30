class CreateBookDetails < ActiveRecord::Migration
  def change
    create_table :book_details do |t|
      t.string :ISBN
      t.string :book_name
      t.string :author
      t.string :language
      t.string :genre
      t.string :version
      t.string :edition
      t.string :publisher
      t.integer :pages
      t.integer :mrp

      t.timestamps
    end
  end
end
