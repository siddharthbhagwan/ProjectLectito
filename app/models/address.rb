class Address < ActiveRecord::Base
  attr_accessible :address_line1, :address_line2, :address_line3, :locality, :pin, :state, :city, :country

  validates :address_line1, :address_line2, :city, :country, :pin , :state, :presence => { :message => "can not be empty"}
  validates :pin, :numericality => true

  belongs_to :user
  
end
