class UserBookController < ApplicationController

	autocomplete :book_detail, :book_name, :full => true, :extra_data => [:id, :isbn, :author, :language, :genre, :version, :edition, :publisher, :pages, :mrp], :data => { :no_matches_label => "" }


	def view
		@userbook = User.find(current_user.id).user_books
	end

	def new
		@bookdetail = BookDetail.new
	end

	def create
		@userbook = UserBook.new
		@bookdetail = BookDetail.find(params[:book_detail][:id])
		@userbook.user_id = current_user.id
		Rails.logger.debug "My debugging message " + @bookdetail.inspect
		@userbook.book_detail_id = @bookdetail.id
		if @userbook.save
			redirect_to mybooks_view_path
		else
			render 'new'
		end
	end

	def delete
		Rails.logger.debug "Entered"
		@userbook = UserBook.find(params[:user_book_id])
		@userbook.destroy
		redirect_to mybooks_view_path
	end
end
