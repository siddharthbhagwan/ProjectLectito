class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :house_no
      t.string :bldg
      t.string :street
      t.string :area
      t.string :city
      t.string :state
      t.integer :pin
      t.string :country

      t.timestamps
    end
  end
end
