class UserBookController < ApplicationController

	autocomplete :book_detail, :book_name, :full => true, :extra_data => [:id, :isbn, :author, :language, :genre, :version, :edition, :publisher, :pages, :mrp], :data => { :no_matches_label => "" }


	def view
		@userbook = User.find(current_user.id).user_books
	end

	def new
		@bookdetail = BookDetail.new
		@address = User.find(current_user.id).addresses
	end

	def create
		@userbook = UserBook.new
		@userbook.user_id = current_user.id
		@userbook.book_detail_id = params[:id]
		@userbook.available_in_city = params[:user_book][:available_in_city]
		@userbook.rental_price = params[:rental_price]
 		if @userbook.save
			redirect_to mybooks_view_path
		else
			render 'new'
		end
	end

	def delete
		@userbook = UserBook.find(params[:user_book_id])
		@userbook.destroy
		redirect_to mybooks_view_path
	end

	def search
		if params[:search_by_book_name] == ""
			@bookdetail = BookDetail.where("author = ?", params[:search_by_author])
		elsif params[:search_by_author] == ""
			@bookdetail = BookDetail.where("book_name = ?", params[:search_by_book_name])
		else
			@bookdetail = BookDetail.where("book_name = ? AND author = ? ", params[:search_by_book_name], params[:search_by_author])
		end

		respond_to do |format|
    		format.html  
    		format.json  { render :json => @bookdetail}
  		end
	end

	def sub_search
		@users_with_book = UserBook.where("book_detail_id = ? ", params[:book_id])
		@users_with_book_in_city = []
		@addresses_with_book_in_city = []
		@users_and_address = []

		@users_with_book.each do |u_wb|
			@address_uwb_in_city = u_wb.user.addresses.find(u_wb.available_in_city)
 			if @address_uwb_in_city.city == params[:city]
				Rails.logger.debug "Reached"
				@users_and_address << u_wb.clone	
				@users_and_address << @address_uwb_in_city	
			end
		end

		respond_to do |format|
    		format.html  
    		format.json  { render :json => @users_and_address}
    	end
	end
end
