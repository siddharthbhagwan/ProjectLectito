class ProfileController < ApplicationController
  load_and_authorize_resource :class => Profile

  def update
    @profile = Profile.find_by_user_id(current_user.id)
    if !@profile
      @profile = Profile.new
      @profile.user_id = current_user.id
  	   if @profile.update_attributes(params[:profile])
          redirect_to edit_profile_path
          flash[:notice] = "Your Profile has been updated"
        else
          render 'edit'
        end
    else
        if @profile.update_attributes(params[:profile])
           redirect_to edit_profile_path
           flash[:notice] = "Your Profile has been updated"
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