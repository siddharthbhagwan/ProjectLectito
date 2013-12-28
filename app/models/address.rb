class Address < ActiveRecord::Base
  attr_accessible :address_line1, :locality, :city, :state, :pin, :country, :landmark

  validates :address_line1, :pin, :presence => { :message => "can not be empty"}
  #validates :pin, :numericality => true

  belongs_to :user

  def address_summary
 	locality + "/" + city
  end

end
