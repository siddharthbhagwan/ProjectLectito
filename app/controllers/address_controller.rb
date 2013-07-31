class AddressController < ApplicationController
  before_filter :require_profile

  # CanCan for authorization on controller actions
  load_and_authorize_resource :class => Address

  def new
  	@address = Address.new
  end

  def update
    @address = Address.find(params[:address_id])
    if @address.update_attributes(params[:address])
      flash[:notice] = "The address has been updated"
      redirect_to address_view_path
    end
  end

  def edit
    @address = Address.find(params[:address_id])
    if  @address.user_id != current_user.id
      redirect_to address_view_path
      flash[:alert] = "You are not authorized to view that address"
    end 
  end

  # List all addresses
  def view
    @address = User.find(current_user.id).addresses

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render :json => @address }
    end
end

  # Create a New Address
  def create
    @address = Address.new(params[:address])
    @address.user_id = current_user.id
    if @address.save
      flash[:notice] = "The address has been added"
      redirect_to address_view_path
    else
      render 'new'
    end
  end

  # Delete the address of the passed Id
  def delete
    @address = Address.find(params[:address_id])
    if  @address.user_id != current_user.id
      redirect_to address_view_path
      flash[:alert] = "You are not authorized to delete that address"
    else
      @address.destroy
      redirect_to address_view_path
      flash[:info] = "The Address has been deleted"
    end
  end

  def autocomplete_area
    @locations = Location.where("area LIKE ? ", "%#{params[:area]}%")

    respond_to do |format|
      format.html  
      format.json { render :json => @locations.to_json }
    end
    
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

end