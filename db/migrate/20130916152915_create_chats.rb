class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :transaction_id
      t.integer :from_user
      t.string :body

      t.timestamps
    end
  end
end
