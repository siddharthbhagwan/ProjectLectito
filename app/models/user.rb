require 'rubygems'
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

  # Associations
  has_one :profile
  has_many :addresses
  has_many :user_books
  has_many :book_details, :through => :user_books 


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

  def checkrole
    if roles_mask == 4
      "User"
    else if roles_mask == 6
      "Administrator"
    end      
    end
  end
end