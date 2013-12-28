class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)    
    if user.admin?
    	can :manage, User
      can :manage, Book
    end
    puts " Checking for user " + user.user?.to_s
    if user.user?
    	can :manage, Profile
    	can :manage, Address
      can :manage, Transaction
      can :manage, Inventory
    end
  end
end