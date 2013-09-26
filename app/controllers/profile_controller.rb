class ProfileController < ApplicationController
  load_and_authorize_resource :class => Profile

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(params[:profile])
    @profile.user_id = current_user.id
    if @profile.save
      flash[:notice] = "Your Profile has been created"
      redirect_to new_address_path
    end
  end

  def update
    @profile = Profile.where(:user_id => current_user.id).take
      if @profile.update_attributes(params[:profile])
         redirect_to edit_profile_path
         flash[:notice] = "Your Profile has been updated"
       else
        render 'edit'
      end
  end

  def edit
    @profile = Profile.where(:id => params[:id]).take
  end

end