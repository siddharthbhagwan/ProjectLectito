class InventoryController < ApplicationController
	before_filter :require_profile
	before_filter :require_address


	def view
		@inventory = User.find(current_user.id).inventories
	end

	def new
		@book = Book.new
		@address = User.find(current_user.id).addresses
	end

	def create
		@inventory = Inventory.new
		@inventory.user_id = current_user.id
		@inventory.book_id = params[:book_id]
		@inventory.available_in_city = params[:inventory][:available_in_city]
		@inventory.rental_price = params[:rental_price]
		@inventory.current_status = params[:current_status]
 		if @inventory.save
			redirect_to mybooks_view_path
		else
			render 'new'
		end
	end

	def edit
		@inventory = Inventory.find(params[:inventory_id])
		@address = User.find(current_user.id).addresses
	end

	def update
		@inventory = Inventory.find(params[:id])
   		@inventory.update_attributes(params[:inventory])
    	redirect_to mybooks_view_path
	end

	def delete
		@inventory = Inventory.find(params[:inventory_id])
		@inventory.destroy
		redirect_to mybooks_view_path
	end

	def search_books
		if params[:search_by_book_name] == ""
			@book = Book.where("author LIKE ?", "%#{params[:search_by_author]}%")
		elsif params[:search_by_author] == ""
			@book = Book.where("book_name LIKE ?", "%#{params[:search_by_book_name]}%")
		else
			@book = Book.where("book_name LIKE ? AND author LIKE ? ", "%#{params[:search_by_book_name]}%"	, "%#{params[:search_by_author]}%")
		end

		respond_to do |format|
    		format.html  
    		format.js
  		end
	end

	def search_books_city
		@users_with_book = Inventory.where("book_id = ? AND user_id != ? ", params[:book_id], current_user.id)
		@users_with_book_in_city = []
		@addresses_with_book_in_city = []
		@users_and_address = []
		@transactions_requested = []

		@users_with_book.each do |u_wb|
			@address_uwb_in_city = u_wb.user.addresses.find(u_wb.available_in_city)
 			if @address_uwb_in_city.city == params[:city]
				@users_and_address << u_wb.clone	
				@users_and_address << @address_uwb_in_city
				@transactions_requested << Transaction.where("borrower_id = ? AND status = ? AND inventory_id = ? ", current_user.id, "Pending", u_wb.id).pluck(:lender_id)
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
		@authors_books = Book.where("author like ?", "%#{params[:author]}%").pluck(:author).uniq

		if @authors_books.empty?
			@authors_books = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @authors_books.to_json }
    	end
	end

	def autocomplete_book_name
		@book_name_books = Book.where("author like ? AND book_name like ?", "%#{params[:author]}%", "%#{params[:book_name]}%").pluck(:book_name)
		
		if @book_name_books.empty?
			@book_name_books = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @book_name_books.to_json }
    	end
	end

	def autocomplete_book_details
		@books = Book.where("author like ? AND book_name like ?", "%#{params[:author]}%", "%#{params[:book_name]}%")
		
		if @books.empty?
			@books = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @books.to_json }
    	end
	end

	def check_inventory_duplication
		@duplicate_books = Inventory.where("user_id = ? AND books_id = ?", current_user.id, params[:book_id])
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
