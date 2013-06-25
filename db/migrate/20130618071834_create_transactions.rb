class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :borrower_id
      t.integer :lender_id
      t.integer :user_book_id
      t.string :status

      t.timestamps
    end
  end
end
