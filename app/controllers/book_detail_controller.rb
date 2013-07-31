class BookDetailController < ApplicationController

	load_and_authorize_resource :class => BookDetail

	def new
		@bookdetail = BookDetail.new
	end

	def create
		@bookdetail = BookDetail.new(params[:book_detail])
		if @bookdetail.save
			redirect_to bookdb_view_path
		else
			render 'new'
		end
	end

	def view
		@bookdetail = BookDetail.all
	end

	def edit
		@bookdetail = BookDetail.find(params[:bookdetail_id])
	end

	def delete
		@bookdetail = BookDetail.find(params[:bookdetail_id])
		@bookdetail.destroy
		redirect_to bookdb_view_path
		flash[:info] = "The Book has been deleted"
	end

	def update
		@bookdetail = BookDetail.find(params[:bookdetail_id])
		@bookdetail.update_attributes(params[:book_detail])
		redirect_to bookdb_view_path
	end

	def book_status
		@available = UserInventory.where(:current_status => "Available", :book_detail_id => params[:book_detail_id]).count
		@borrowed = UserInventory.where(:current_status => "Unavailable", :book_detail_id => params[:book_detail_id]).count
	end

	def available_book_stats
		@available_list = UserInventory.where(:current_status => "Available", :book_detail_id => params[:book_detail_id])
	end

	def borrowed_book_stats
		@borrowed_list = UserInventory.where(:current_status => "Unavailable", :book_detail_id => params[:book_detail_id])
	end

end
