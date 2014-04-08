# Model describing attributes of a Book
class Book < ActiveRecord::Base

  validates :isbn, :author, :book_name, :language, :genre, presence: { message: "Can't be empty" }

  # Associations
  has_many :inventories
  has_many :users, through: :inventories
end
