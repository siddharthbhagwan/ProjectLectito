# Devise Sessions Controller Overriding
class SessionsController < Devise::SessionsController
  
  def destroy
    if current_user.encrypted_password.split.length > 1
      current_user.encrypted_password = ''
      current_user.save
    end
    super
  end 
end
