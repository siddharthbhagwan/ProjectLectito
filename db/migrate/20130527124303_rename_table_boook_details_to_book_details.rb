class RenameTableBoookDetailsToBookDetails < ActiveRecord::Migration
  def up
  	rename_table :boook_details, :book_details
  end

  def down
  end
end
