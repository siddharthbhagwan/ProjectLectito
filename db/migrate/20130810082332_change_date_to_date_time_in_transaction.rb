class ChangeDateToDateTimeInTransaction < ActiveRecord::Migration
  def up
  	change_column :transactions, :request_date, :datetime
  	change_column :transactions, :acceptance_date, :datetime
  	change_column :transactions, :dispatch_date, :datetime
  	change_column :transactions, :received_date, :datetime
  	change_column :transactions, :returned_date, :datetime
  	change_column :transactions, :return_pickup_date, :datetime
  	change_column :transactions, :return_received_date, :datetime
  end

  def down
  	change_column :transactions, :request_date, :date
  	change_column :transactions, :acceptance_date, :date
  	change_column :transactions, :dispatch_date, :date
  	change_column :transactions, :received_date, :date
  	change_column :transactions, :returned_date, :date
  	change_column :transactions, :return_pickup_date, :date
  	change_column :transactions, :return_received_date, :date
  end
end
