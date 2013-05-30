class RenameBooksToBookDb < ActiveRecord::Migration
  def up
  	rename_table :books, :boook_details
  end

  def down
  	rename_table :bookdetails, :books
  end
end
