class AddDeliveryToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :delivery, :boolean
  end
end
