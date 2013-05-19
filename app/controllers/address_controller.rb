class AddressController < ApplicationController
  load_and_authorize_resource :class => Address
  autocomplete :location, :area , :full => true, :extra_data => [:city, :state, :pincode], :data => { :no_matches_label => "" }

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
    if  @address.user_id != current_user.id
        redirect_to address_view_path, :alert => "You are not authorized to view that address"
    end 
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
    if  @address.user_id != current_user.id
        redirect_to address_view_path, :alert => "You are not authorized to delete that address"
    else
        @address.destroy
        redirect_to address_view_path
        flash[:info] = "The Address has been deleted"
    end
  end

end