class Address < ActiveRecord::Base
  attr_accessible :address_line1, :locality, :city, :state, :pin, :country

  validates :address_line1, :city, :country, :pin , :state, :presence => { :message => "can not be empty"}
  #validates :pin, :numericality => true

  belongs_to :user

  def address_summary
  	address_line1 + "/" + locality + "/" + city
  end

end
