# Model describing attributes of a Book
class Book < ActiveRecord::Base
  attr_accessible :isbn, :author, :book_name, :edition, :genre, :language,
                  :mrp, :pages, :publisher, :version

  # validates :ISBN,:author,:book_name,presence: {message: "Cant be empty"}

  # Associations
  has_many :inventories
  has_many :users, through: :inventories
end
