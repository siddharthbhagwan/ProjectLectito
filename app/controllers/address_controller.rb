# Address Controller
class AddressController < ApplicationController
  include ApplicationHelper
  before_action :require_profile
  before_action :otp_verified?

  # CanCan for authorization on controller actions
  load_and_authorize_resource class: Address

  def new
    @address = Address.new
    chatbox
  end

  def update
    @address = Address.where(id: params[:id]).first
    chatbox
    if @address.update_attributes(address_params)
      flash[:notice] = 'The address has been updated '
      redirect_to address_index_path
    end
  end

  def edit
    @address = Address.where(id: params[:id]).first
    chatbox
    if  @address.user_id != current_user.id
      redirect_to address_path
      flash[:alert] = 'You are not authorized to view that address '
    end
  end

  # List all addresses
  def index
    @address = User.where(id: current_user.id).first.addresses
    chatbox

    respond_to do |format|
      format.html  # index.html.erb
      format.json  { render json: @address }
    end
  end

  # Create a New Address
  def create
    @address = Address.create(address_params)
    @address.user_id = current_user.id
    if @address.save
      flash[:notice] = 'The address has been added '
      if current_user.addresses.count == 1
        redirect_to inventory_search_path
      else 
        redirect_to address_index_path
      end  
    else
      render 'new'
    end
  end

  # Delete the address of the passed Id
  def destroy
    @address = Address.where(id: params[:id]).first
    if  @address.user_id != current_user.id
      redirect_to address_index_path
      flash[:alert] = 'You are not authorized to delete that address '
    else
      @address.destroy
      redirect_to address_index_path
      flash[:info] = 'The Address has been deleted '
    end
  end

  def autocomplete_area
    @locations = Location.where("lower(area) LIKE ? ", "%#{params[:area].downcase}%")

    respond_to do |format|
      format.json { render json: @locations.to_json }
    end
  end

  private

  def address_params
    params.require(:address).permit(:address_line1, :pin)
  end

  def require_profile
    if current_user.profile.nil?
      flash[:notice] = 'Please complete your profile '
      redirect_to new_profile_path
    else
      return false
    end
  end
end
