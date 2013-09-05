class InventoryController < ApplicationController
	before_action :require_profile, :require_address

	def index
		@inventory = User.where(:id => current_user.id).take.inventories
	end

	def new
		@book = Book.new
		@address = User.where(:id => current_user.id).take.addresses
	end

	def create
		@inventory = Inventory.new
		@inventory.user_id = current_user.id
		@inventory.book_id = params[:book_id]
		@inventory.available_in_city = params[:inventory][:available_in_city]
		@inventory.rental_price = params[:rental_price]
		@inventory.status = params[:current_status]
 		if @inventory.save
			redirect_to inventory_index_path
			flash[:notice] = "The book has been added to your inventory"
		else
			render 'new'
		end
	end

	def edit
		@inventory = Inventory.where(:id => params[:id]).take
		@address = User.where(:id => current_user.id).take.addresses
	end

	def update
		#FIXME Update_attributes needs to be done individually :S
		@inventory = Inventory.where(:id => params[:id]).take
   		@inventory.update_attributes(params[:inventory])
   		@inventory.update_attributes(:rental_price => params[:rental_price])
   		@inventory.update_attributes(:status => params[:current_status])
   		if @inventory.save
   			flash[:notice] = "The inventory has been updated"
    		redirect_to inventory_index_path
    	end
	end

	def destroy
		@inventory = Inventory.where(:id => params[:id]).take
		@inventory.destroy
		redirect_to inventory_index_path
		flash[:notice] = "The book has been deleted from your inventory"
	end

	def search_books
		if params[:search_by_book_name] == ""
			@books = Book.where("author LIKE ?", "%#{params[:search_by_author]}%")
		elsif params[:search_by_author] == ""
			@books = Book.where("book_name LIKE ?", "%#{params[:search_by_book_name]}%")
		else
			@books = Book.where("book_name LIKE ? AND author LIKE ? ", "%#{params[:search_by_book_name]}%", "%#{params[:search_by_author]}%")
		end

		@book_array = []

		@books.each do |book|
			@users_with_book = Inventory.where("book_id = ? AND user_id != ? AND status = ?", book, current_user.id, "Available").take

			if !@users_with_book.nil?

				# Of all Users who have the book, check who all are in the city as selected by user
				# Merge this list with the address of each user who meets the criteria.
				
				@address_uwb_in_city = @users_with_book.user.addresses.where(:id => @users_with_book.available_in_city).take
				@delivery_uwb = @users_with_book.user.is_delivery

				if current_user.is_delivery
		 			if ((@address_uwb_in_city.city == params[:city]) and (current_user.is_delivery == @delivery_uwb))
						@book_array << book
					end
				else
					@book_array << book
				end				
			end
		end	

		respond_to do |format|
    		format.html  
    		format.js
  		end
	end

	def search_books_city
		# Find all users apart from self, who have the book
		@users_with_book = Inventory.where("book_id = ? AND user_id != ? AND status = ? ", params[:book_id], current_user.id, "Available")

		@users_with_book_in_city = []
		@addresses_with_book_in_city = []
		@users_and_address = []
		@transactions_requested = []

		# Of all Users who have the book, check who all are in the city as selected by user
		# Merge this list with the address of each user who meets the criteria.
		@users_with_book.each do |u_wb|
			#address of user who has the book
			@address_uwb_in_city = u_wb.user.addresses.where(:id => u_wb.available_in_city).take

			#delivery mode of user who was the book
			@delivery_uwb = u_wb.user.is_delivery

			#If current User's Delivery mode is delivery only, look for lenders with delivery only
			#If current user's Delivery mode is pickup, look for both, delivery and pick up
			#TODO make the if more efficient
			if current_user.is_delivery
	 			if ((@address_uwb_in_city.city == params[:city]) and (current_user.is_delivery == @delivery_uwb))
	 				# If criteria matches, store Inventory Details woth corresponding Address in an array
					@users_and_address << u_wb.clone	
					@users_and_address << @address_uwb_in_city
					@transactions_requested << Transaction.where(:borrower_id => current_user.id, :status => "Pending", :inventory_id => u_wb.id).pluck(:inventory_id)
				end
			else
				if @address_uwb_in_city.city == params[:city]
					@users_and_address << u_wb.clone	
					@users_and_address << @address_uwb_in_city
					@transactions_requested << Transaction.where(:borrower_id => current_user.id, :status => "Pending", :inventory_id => u_wb.id).pluck(:inventory_id)
				end
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
		@borrow = Transaction.where(:borrower_id => current_user.id, :status => "Pending").last(5)
		@lend = Transaction.where(:lender_id => current_user.id, :status => "Pending")
		@accept = Transaction.where("lender_id = ? AND ( status = ? OR status = ?)", current_user.id, "Accepted", "Returned" )
		@current = Transaction.where(:borrower_id => current_user.id, :status => "Accepted")
		@received = Transaction.where(:lender_id => current_user.id, :status => "Returned")
	end

	def autocomplete_author
		@authors_books = Book.where("author like ? AND book_name like ?", "%#{params[:author]}%", "%#{params[:book_name]}%").pluck(:author).uniq

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
		@books = Book.where("book_name like ?", "%#{params[:book_name]}%")
		
		if @books.empty?
			@books = ["No Matching Results Found"]
		end

		respond_to do |format|
    		format.html  
    		format.json { render :json => @books.to_json }
    	end
	end

	def check_inventory_duplication
		@duplicate_books = Inventory.where(:user_id => current_user.id, books_id => params[:book_id])
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
    		redirect_to new_address_path
    	else
    		return false
    	end
  	end	
end
