class AddUidToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :Uid, :string
  end
end
