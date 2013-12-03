class Profile < ActiveRecord::Base

  attr_accessible :DoB, :user_first_name, :gender, :user_last_name, :user_phone_no, :last_update, :contact_via_sms, :delivery

  belongs_to :user

  validates :user_first_name, :user_last_name, :gender, :user_phone_no,:presence => true
  validates :DoB, :presence => { :message => "Please Select a value" }
  validates :user_phone_no, :numericality => true, length: { is: 10 }
  
  validates_inclusion_of :gender, :in => %w( M F ), :message => " can only be 'M' or 'F'"

  def sms_updates
    if contact_via_sms?
      "Yes"
    else
      "No"
    end
  end

  def chat_name
    user_first_name[0,1] + user_last_name[0,1]
  end
end
