class BookDetail < ActiveRecord::Base
  attr_accessible :isbn, :author, :book_name, :edition, :genre, :language, :mrp, :pages, :publisher, :version

  #validates :ISBN, :author,:book_name, :presence => {:message => "Cant be empty"}

  #Associations
  has_many :user_books
  has_many :users, :through => :user_books


end

