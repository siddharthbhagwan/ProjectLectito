class Address < ActiveRecord::Base
  attr_accessible :address_line1, :pin
  validates :address_line1, :pin, presence: { message: "can not be empty"}
  #validates :pin, :numericality => true

  belongs_to :user

  def address_summary
 	  self.address_line1[0..25].gsub(/\r/," ").gsub(/\n/," ") + "..."
  end

end
