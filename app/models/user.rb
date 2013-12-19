require 'role_model'
class User < ActiveRecord::Base
  
  include RoleModel
 # attr_accessor :roles_mask
  roles_attribute :roles_mask
  roles :god_mode, :admin, :user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable,
  		 :lockable, :timeoutable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :roles_mask
  # attr_accessible :title, :body

  # Active Record Associations
  has_one :profile, :dependent => :destroy
  has_many :addresses, :dependent => :destroy
  has_many :inventories ,:dependent => :destroy
  has_many :books, :through => :inventories
  has_many :transactions, :dependent => :destroy

  # Returns Full name, or Email, which ever is available
  def welcome_name
    if profile.nil? or (profile.user_first_name.nil? and profile.user_last_name.nil?)
      email 
    else
      profile.user_first_name + " " + profile.user_last_name
    end
  end

  def full_name
    profile.user_first_name + " " + profile.user_last_name
  end

  # Set Users Current Status as active by default
  def default_current_status
    current_status ||= "Active"
  end

  # Returns delivery option of user
  def is_delivery
    profile.delivery
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid, :email)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
     # user.username = auth.info.nickname
      user.email = auth.info.email
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
        super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  # Function to return the role assigned
  def checkrole
    if roles_mask == 4
      "User"
    elsif roles_mask == 6
      "Administrator"
    end      
  end

end