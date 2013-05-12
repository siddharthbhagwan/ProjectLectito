class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)
    if user.user?
        Rails.logger.debug "Hererererererererere"
        can :manage, Profile
     end
  end
end
