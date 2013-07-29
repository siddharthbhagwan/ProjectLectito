class UserBookController < ApplicationController
	before_filter :require_profile
	before_filter :require_address

	autocomplete :book_detail, :book_name, :full => true, :extra_data => [:id, :isbn, :author, :language, :genre, :version, :edition, :publisher, :pages, :mrp], :data => { :no_matches_label => "" }
	autocomplete :book_detail, :author, :full => true


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
		@userbook.availability = params[:availability]
 		if @userbook.save
			redirect_to mybooks_view_path
		else
			render 'new'
		end
	end

	def edit
		@userbook = UserBook.find(params[:user_book_id])
		@address = User.find(current_user.id).addresses
	end

	def update
		@userbook = UserBook.find(params[:id])
   		@userbook.update_attributes(params[:user_book])
    	redirect_to mybooks_view_path
	end

	def delete
		@userbook = UserBook.find(params[:user_book_id])
		@userbook.destroy
		redirect_to mybooks_view_path
	end

	def search_books
		if params[:search_by_book_name] == ""
			@bookdetail = BookDetail.where("author LIKE ?", "%#{params[:search_by_author]}%")
		elsif params[:search_by_author] == ""
			@bookdetail = BookDetail.where("book_name LIKE ?", "%#{params[:search_by_book_name]}%")
		else
			@bookdetail = BookDetail.where("book_name LIKE ? AND author LIKE ? ", "%#{params[:search_by_book_name]}%"	, "%#{params[:search_by_author]}%")
		end

		respond_to do |format|
    		format.html  
    		format.js
  		end
	end

	def search_books_city
		@users_with_book = UserBook.where("book_detail_id = ? AND user_id != ? ", params[:book_id], current_user.id)
		@users_with_book_in_city = []
		@addresses_with_book_in_city = []
		@users_and_address = []
		@transactions_requested = []

		@users_with_book.each do |u_wb|
			@address_uwb_in_city = u_wb.user.addresses.find(u_wb.available_in_city)
 			if @address_uwb_in_city.city == params[:city]
				@users_and_address << u_wb.clone	
				@users_and_address << @address_uwb_in_city
				@transactions_requested << Transaction.where("borrower_id = ? AND status = ? AND user_book_id = ? ", current_user.id, "Pending", u_wb.id).pluck(:lender_id)
			end
		end

		@transactions_requested = @transactions_requested.flatten
		@transactions_requested = @transactions_requested.map(&:inspect).join(', ')

		respond_to do |format|
    		format.html  
    		format.js
    	end
	end

	def search
		@borrow = Transaction.where("borrower_id = ? ", current_user.id).last(5)
		@lend = Transaction.where("lender_id = ? AND status = ? ", current_user.id, "Pending")
		@accept = Transaction.where("lender_id = ? AND status = ?", current_user.id, "Accepted")
	end

	def autocomplete_author
		@authors_books = BookDetail.where("author like ?", "%#{params[:author]}%").pluck(:author).uniq

		if @authors_books.empty?
			@authors_books = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @authors_books.to_json }
    	end
	end

	def autocomplete_book_name
		@book_name_books = BookDetail.where("author like ? AND book_name like ?", "%#{params[:author]}%", "%#{params[:book_name]}%").pluck(:book_name)
		
		if @book_name_books.empty?
			@book_name_books = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @book_name_books.to_json }
    	end
	end

	def autocomplete_book_details
		@book_details = BookDetail.where("author like ? AND book_name like ?", "%#{params[:author]}%", "%#{params[:book_name]}%")
		
		if @book_details.empty?
			@book_details = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @book_details.to_json }
    	end
	end

	def check_user_book_duplication
		@duplicate_books = UserBook.where("user_id = ? AND book_detail_id = ?", current_user.id, params[:book_id])
	end

	private

	def require_profile
    	if current_user.profile.nil?
    		flash[:notice] = "Please complete your profile"
    		redirect_to profile_edit_path
    	else
    		return false
    	end
  	end

  	def require_address
    	if current_user.addresses.empty?
    		flash[:notice] = "Please Enter at least one Address"
    		redirect_to address_view_path
    	else
    		return false
    	end
  	end	
end
