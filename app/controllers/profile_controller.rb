class ProfileController < ApplicationController
  load_and_authorize_resource :class => Profile
  def new
  	@profile = Profile.new
  end

  def update
    @profile = Profile.find_by_user_id(current_user.id)
    if !@profile
      @profile = Profile.new
      @profile.user_id = current_user.id
  	   if @profile.update_attributes(params[:profile])
          redirect_to address_new_path
        else
          render 'new'
        end
    else
        if @profile.update_attributes(params[:profile])
           redirect_to address_view_path
         else
          render 'edit'
        end
    end
  end

  def edit
    @profile = Profile.find_by_user_id(current_user.id)
    if !@profile
        @profile = Profile.new
    end
  end
end