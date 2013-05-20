class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)    
    
    if user.admin?
    	can :manage, User
    end

    if user.user?
    	can :manage, Profile
    	can :manage, Address
    end
  end
end