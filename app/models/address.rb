class Address < ActiveRecord::Base
  
  validates :address_line1, :pin, presence: { message: "Can't be empty" }
  validates :pin, numericality: true, inclusion: { in: 100000..999999 , message: 'must have 6 digits' }

  belongs_to :user
  has_many :inventories, foreign_key: :available_in_city

  def address_summary
 	  # self.address_line1[0..25].gsub(/\r/," ").gsub(/\n/," ") + "..."
    self.address_line1.gsub(/\r/,'')#.gsub(/\n/,'')
  end

  def address_summary_newline
    self.address_line1.gsub(/\r/,'').gsub(/\n/,'')
  end
end
