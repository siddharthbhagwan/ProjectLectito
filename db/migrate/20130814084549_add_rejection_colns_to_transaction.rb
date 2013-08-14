class AddRejectionColnsToTransaction < ActiveRecord::Migration
  def change
  	add_column :transactions, :rejection_date, :datetime
  	add_column :transactions, :rejection_reason, :string
  end
end
