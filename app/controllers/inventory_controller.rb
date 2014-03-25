class InventoryController < ApplicationController
	include ApplicationHelper
	#before_action :require_profile, :require_address
	if :authenticate_user!
		before_action :require_profile
		before_action :otp_verified?
		before_action :require_address
	end

	def index
		@inventory = User.where(id: current_user.id).take.inventories.where(deleted: :false)
		chatbox
	end

	def new
		@book = Book.new
		@address = User.where(id: current_user.id).take.addresses
		chatbox
	end

	def create
	#TODO - Send New book params in a form so strong params can be updated
		if params[:book_id] == '0'
			new_book = Book.new
			new_book.book_name = params[:book_name]
			new_book.isbn = params[:isbn]
			new_book.author = params[:author]
			new_book.language = params[:language]
			new_book.genre = params[:genre]

			if new_book.save!
				@inventory = Inventory.new(inventory_params)
				@inventory.user_id = current_user.id
				@inventory.book_id = new_book.id
				@inventory.status = params[:status]
				@inventory.no_of_borrows = 0
				if @inventory.save!
					redirect_to inventory_index_path
					flash[:notice] = 'The book has been added to your inventory'
				else
					render 'new'
				end
			end	
		else
			@inventory = Inventory.new
			@inventory.user_id = current_user.id
			@inventory.book_id = params[:book_id]
			@inventory.available_in_city = params[:inventory][:available_in_city]
			#@inventory.rental_price = params[:rental_price]
			@inventory.status = params[:status]
			@inventory.no_of_borrows = 0
	 		if @inventory.save!
				redirect_to inventory_index_path
				flash[:notice] = 'The book has been added to your inventory'
			else
				render 'new'
			end
		end
		
		chatbox
	end

	def edit
		@inventory = Inventory.where(id: params[:id]).take
		@address = User.where(id: current_user.id).take.addresses
		chatbox
	end

	def update
		#FIXME Update_attributes needs to be done individually :S
		@inventory = Inventory.where(id: params[:id]).take
   		@inventory.update_attributes(inventory_params)
   		#@inventory.rental_price = params[:rental_price]
   		@inventory.status = params[:status]
   		
   		if @inventory.save!
    		redirect_to inventory_index_path
    		flash[:notice] = 'The inventory has been updated'
    	end
	end

	def destroy
		@inventory = Inventory.where(id: params[:id]).take
		@inventory.deleted = true
		@inventory.status = 'Deleted'
		if @inventory.save!
			redirect_to inventory_index_path
			flash[:notice] = 'The book has been deleted from your inventory'
		end
	end

	def search_books
		if params[:search_by_book_name] == ""
			@books = Book.where('author LIKE ?', "%#{params[:search_by_author]}%")
		elsif params[:search_by_author] == ""
			@books = Book.where('book_name LIKE ?', "%#{params[:search_by_book_name]}%")
		else
			@books = Book.where('book_name LIKE ? AND author LIKE ? ', "%#{params[:search_by_book_name]}%", "%#{params[:search_by_author]}%")
		end

		@book_array = []

		@books.each do |book|
			if user_signed_in?
				@users_with_book = Inventory.where('book_id = ? AND user_id != ? AND status = ? AND deleted = ?', book, current_user.id, "Available", false).take
			else
				@users_with_book = Inventory.where('book_id = ? AND status = ? AND deleted = ?', book, "Available", false).take
			end

			if !@users_with_book.nil?

				# Of all Users who have the book, check who all are in the city as selected by user
				# Merge this list with the address of each user who meets the criteria.
				
				@address_uwb_in_city = @users_with_book.user.addresses.where(id: @users_with_book.available_in_city).take
				@delivery_uwb = @users_with_book.user.is_delivery

				if user_signed_in?
					if (@address_uwb_in_city.city == params[:city]) 
						@book_array << book
					end
					# if current_user.is_delivery
			 	# 		if ((@address_uwb_in_city.city == params[:city]) and (current_user.is_delivery == @delivery_uwb))
					# 		@book_array << book
					# 	end
					# else
					# 	@book_array << book
					# end
				else
					if @address_uwb_in_city.city == params[:city]
						@book_array << book
					end
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
	 	if user_signed_in?
			@users_with_book = Inventory.where('book_id = ? AND user_id != ? AND status = ? AND deleted = ?', params[:book_id], current_user.id, "Available", false)
		else
			@users_with_book = Inventory.where('book_id = ? AND status = ? AND deleted = ?', params[:book_id], 'Available', false)
		end
		
		@users_with_book_in_city = []
		@addresses_with_book_in_city = []
		@users_and_address = []
		@transactions_requested = []

		# Of all Users who have the book, check who all are in the city as selected by user
		# Merge this list with the address of each user who meets the criteria.
		@users_with_book.each do |u_wb|
			#address of user who has the book
			@address_uwb_in_city = u_wb.user.addresses.where(id: u_wb.available_in_city).take

			#delivery mode of user who was the book
			@delivery_uwb = u_wb.user.is_delivery

			#If current User's Delivery mode is delivery only, look for lenders with delivery only
			#If current user's Delivery mode is pickup, look for both, delivery and pick up
			#TODO make the if more efficient
			if user_signed_in?
				if @address_uwb_in_city.city == params[:city]
					@users_and_address << u_wb.clone	
					@users_and_address << @address_uwb_in_city
					@transactions_requested << Transaction.where(borrower_id: current_user.id, status: 'Pending', inventory_id: u_wb.id).pluck(:inventory_id)
				end
				# if current_user.is_delivery
		 	# 		if ((@address_uwb_in_city.city == params[:city]) and (current_user.is_delivery == @delivery_uwb))
		 	# 			# If criteria matches, store Inventory Details woth corresponding Address in an array
				# 		@users_and_address << u_wb.clone	
				# 		@users_and_address << @address_uwb_in_city
				# 		@transactions_requested << Transaction.where(:borrower_id => current_user.id, :status => "Pending", :inventory_id => u_wb.id).pluck(:inventory_id)
				# 	end
				# else
				# 	if @address_uwb_in_city.city == params[:city]
				# 		@users_and_address << u_wb.clone	
				# 		@users_and_address << @address_uwb_in_city
				# 		@transactions_requested << Transaction.where(:borrower_id => current_user.id, :status => "Pending", :inventory_id => u_wb.id).pluck(:inventory_id)
				# 	end
				# end
			else
				if @address_uwb_in_city.city == params[:city]
					@users_and_address << u_wb.clone	
					@users_and_address << @address_uwb_in_city
					@transactions_requested << Transaction.where(status: 'Pending', inventory_id: u_wb.id).pluck(:inventory_id)
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
		if user_signed_in?
			@borrow = Transaction.where(borrower_id: current_user.id, status: 'Pending').last(5)
			@lend = Transaction.where(lender_id: current_user.id, status: 'Pending')
			@accept = Transaction.where('lender_id = ? AND ( status = ? OR status = ? OR status = ?)', current_user.id, 'Accepted', 'Returned', 'Received Borrower' )
			@current = Transaction.where('borrower_id = ? AND ( status = ? OR status = ?)', current_user.id, 'Accepted', 'Received Borrower' )
			@received = Transaction.where(lender_id: current_user.id, status: 'Returned')

			chatbox  
		else
			@borrow = nil
			@lend = nil
			@accept = nil
			@current = nil
			@received = nil
		end
	end

	def autocomplete_author
		if params[:book_name].nil?
			@authors_books = Book.where('lower(author) like ? ', "%#{params[:author].downcase}%").pluck(:author).uniq
		else
			@authors_books = Book.where('lower(author) like ? AND lower(book_name) like ?', "%#{params[:author].downcase}%", "%#{params[:book_name]}%").pluck(:author).uniq
		end

		respond_to do |format|
  		format.html  
  		format.json { render json: @authors_books.to_json }
  	end
	end

	def autocomplete_book_name
		@book_name_books = Book.where('lower(author) like ? AND lower(book_name) like ?', "%#{params[:author].downcase}%", "%#{params[:book_name].downcase}%").pluck(:book_name)

		respond_to do |format|
  		format.html  
  		format.json { render json: @book_name_books.to_json }
  	end
	end

	def autocomplete_book_details
		@books = Book.where('lower(book_name) like ?', "%#{params[:book_name].downcase}%")

		respond_to do |format|
  		format.html  
  		format.json { render json: @books.to_json }
  	end
	end

	private

	def inventory_params
		params.require(:inventory).permit(:available_in_city)
	end

	def require_profile
		if user_signed_in?
    	if current_user.profile.nil?
    		flash[:notice] = 'Please complete your profile'
    		redirect_to new_profile_path
    	else
    		return false
    	end
  	end
  end	

	def require_address
		if user_signed_in?
			if !current_user.profile.nil? && current_user.otp_verification
	    	if current_user.addresses.empty?
	    		flash[:notice] = 'Please Enter at least one Address'
	    		redirect_to new_address_path
	    	else
	    		return false
	    	end
	    end
    end
	end	
end
