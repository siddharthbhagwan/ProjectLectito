# Controller for Book Model
class BookController < ApplicationController
  include ApplicationHelper
  load_and_authorize_resource class: :Book

  def new
    @book = Book.new
    chatbox
  end

  def create
    @book = Book.new(params[:book])
    if @book.save
      redirect_to book_index_path
    else
      render 'new'
    end
  end

  def index
    @book = Book.all
    chatbox
  end

  def edit
    @book = Book.find(params[:id])
    chatbox
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to book_index_path
    flash[:info] = 'The Book has been deleted'
  end

  def update
    @book = Book.find(params[:id])
    @book.update_attributes(params[:book])
    redirect_to book_index_path
  end

  def history

  end

  def book_status
    @available = Inventory.where(deleted: :false,
                                 status: 'Available',
                                 book_id: params[:book_id]).count

    @borrowed = Inventory.where(deleted: :false,
                                status: 'Unavailable',
                                book_id: params[:book_id]).count
  end

  def available_book_stats
    @available_list = Inventory.where(deleted: :false,
                                      status: 'Available',
                                      book_id: params[:book_id])
  end

  def borrowed_book_stats
    @borrowed_list = Inventory.where(deleted: :false,
                                     status: 'Unavailable',
                                     book_id: params[:book_id])
  end
end
