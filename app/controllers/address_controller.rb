class AddressController < ApplicationController
  def new
  	@address = Address.new
  end

  def update
    @address = Address.find(params[:address_id])
    @address.update_attributes(params[:address])
    redirect_to address_view_path
  end

  def edit
    @address = Address.find(params[:address_id])
  end

  def view
    @address = User.find(current_user.id).addresses
  end

  def create
    @address = Address.new(params[:address])
    @address.user_id = current_user.id
    if @address.save
      redirect_to address_view_path
    else
      render 'new'
    end
  end

  def delete
    @address = Address.find(params[:address_id])
    @address.destroy
  end
end