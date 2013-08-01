class Profile < ActiveRecord::Base
  before_save :default_current_status

  attr_accessible :DoB, :user_first_name, :gender, :user_last_name, :user_phone_no, :last_update, :contact_via_sms

  belongs_to :user

  validates :user_first_name, :user_last_name, :gender, :user_phone_no, :presence => true
  validates :DoB, :presence => { :message => "Please Select a value" }
  validates :user_phone_no, :numericality => true, length: {minimum: 10, maximum: 10}

  validates_inclusion_of :gender, :in => %w( M F ), :message => " can only be 'M' or 'F'"

  # Set Users Current Status as active by default
  def default_current_status
  	self.current_status ||= "Active"
  end

  def sms_updates
    if self.contact_via_sms?
      "Yes"
    else
      "No"
    end
  end

end
