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
		@available = UserBook.where(:availability => "Yes", :book_detail_id => params[:book_detail_id]).count
		@available_list = UserBook.where(:availability => "Yes", :book_detail_id => params[:book_detail_id])
		@borrowed = UserBook.where(:availability => "No", :book_detail_id => params[:book_detail_id]).count
	end

	def available_book_stats
		@available_list = UserBook.where(:availability => "Yes", :book_detail_id => params[:book_detail_id])
		Rails.logger.debug "adsasdasda " + @available_list.inspect
	end

end
