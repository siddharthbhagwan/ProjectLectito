class AddContactViaSmsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :contact_via_sms, :boolean
  end
end
