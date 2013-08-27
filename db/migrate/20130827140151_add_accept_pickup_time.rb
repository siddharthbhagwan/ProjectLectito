class AddAcceptPickupTime < ActiveRecord::Migration
  def change
  	add_column :transactions, :accept_pickup_date, :string
  end
end
