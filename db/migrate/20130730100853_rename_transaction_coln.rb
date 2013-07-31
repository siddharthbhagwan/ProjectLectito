class RenameTransactionColn < ActiveRecord::Migration
  def up
  	rename_column :transactions, :user_book_id, :user_inventory_id
  end

  def down
  	rename_column :transactions, :user_inventory_id, :user_book_id
  end
end
