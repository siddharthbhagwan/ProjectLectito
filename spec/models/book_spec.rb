require 'spec_helper'

# 5 tests

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

  it 'Should have an genre' do
    new_book = Book.new(genre: '')
    new_book.should have(1).error_on(:genre)
  end

  it 'Should have an language' do
    new_book = Book.new(language: '')
    new_book.should have(1).error_on(:language)
  end

end