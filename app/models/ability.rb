class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)    
    
    if user.admin?
    	can [:admin_view, :admin_index, :admin_edit], :admin
    end

    if user.user?
    	can :manage, Profile
    	can :manage, Address
    end
  end
end