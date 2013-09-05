class BookController < ApplicationController

	load_and_authorize_resource :class => Book

	def new
		@book = Book.new
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
	end

	def edit
		@book = Book.find(params[:id])
	end

	def destroy
		@book = Book.find(params[:id])
		@book.destroy
		redirect_to book_index_path
		flash[:info] = "The Book has been deleted"
	end

	def update
		@book = Book.find(params[:id])
		@book.update_attributes(params[:book])
		redirect_to book_index_path
	end

	def book_status
		@available = Inventory.where(:status => "Available", :book_id => params[:book_id]).count
		@borrowed = Inventory.where(:status => "Unavailable", :book_id => params[:book_id]).count
	end

	def available_book_stats
		@available_list = Inventory.where(:status => "Available", :book_id => params[:book_id])
	end

	def borrowed_book_stats
		@borrowed_list = Inventory.where(:status => "Unavailable", :book_id => params[:book_id])
	end

end
