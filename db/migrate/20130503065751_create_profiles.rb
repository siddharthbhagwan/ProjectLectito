class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :First_Name
      t.string :Last_Name
      t.date :DoB
      t.string :Gender

      t.timestamps
    end
  end
end
