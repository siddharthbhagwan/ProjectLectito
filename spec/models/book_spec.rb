require 'spec_helper'

# 7 tests

describe Book do
  
  it 'Should have an ISBN' do
    new_book = Book.new(isbn: '')
    new_book.should have(1).error_on(:isbn)
  end

  it 'Should have an book name' do
    new_book = Book.new(book_name: '')
    new_book.should have(1).error_on(:book_name)
  end

  it 'Should have an author' do
    new_book = Book.new(author: '')
    new_book.should have(1).error_on(:author)
  end

  it 'Should have a genre' do
    new_book = Book.new(genre: '')
    new_book.should have(1).error_on(:genre)
  end

  it 'Should have a language' do
    new_book = Book.new(language: '')
    new_book.should have(1).error_on(:language)
  end

  # Associations

  it 'Should have many inventories ' do
    inventory_association = Book.reflect_on_association(:inventories)
    inventory_association.macro.should == :has_many
  end

  it 'Should have many users through inventories ' do
    user_association = Book.reflect_on_association(:users)
    user_association.macro.should == :has_many
    user_association.options[:through].should == :inventories
  end

end