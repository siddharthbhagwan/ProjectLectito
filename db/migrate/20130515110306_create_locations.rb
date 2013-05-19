class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :area
      t.string :city
      t.string :state
      t.string :pincode

      t.timestamps
    end
  end
end
