class AddColnsToTransaction < ActiveRecord::Migration
  def change
  	add_column :transactions, :request_date, :date
  	add_column :transactions, :acceptance_date, :date
  	add_column :transactions, :dispatch_date, :date
  	add_column :transactions, :received_date, :date
  	add_column :transactions, :borrow_duration, :integer
  	add_column :transactions, :renewal_count, :integer
  	add_column :transactions, :returned_date, :date
  	add_column :transactions, :return_pickup_date, :date
  	add_column :transactions, :return_received_date, :date
  	add_column :transactions, :book_condition, :date
  	add_column :transactions, :total_commission, :float
  end
end
