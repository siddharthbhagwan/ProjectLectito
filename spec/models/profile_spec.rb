require 'spec_helper'

# 12 Tests

describe Profile do

  it 'Should have a first name' do
    new_profile = Profile.new(user_first_name: '' )
    new_profile.should have(1).error_on(:user_first_name)
  end

  it 'Should have a last name' do
    new_profile = Profile.new(user_last_name: '')
    new_profile.should have(1).error_on(:user_last_name)
  end

  it 'Should have a DoB' do
    new_profile = Profile.new(DoB: '')
    new_profile.should have(1).error_on(:user_last_name)
  end

  it 'Should have a gender' do
    new_profile = Profile.new(gender: '')
    new_profile.should have(2).error_on(:gender)
  end

  it 'Should have a gender either M or F' do
    new_profile = Profile.new(gender: 'Some Text Thats not M or F')
    new_profile.should have(1).error_on(:gender)
  end

  it 'Should have a phone number' do
    new_profile = Profile.new(user_phone_no: '')
    new_profile.should have(3).error_on(:user_phone_no)
  end

  it 'Should have a phone number thats a number' do
    new_profile = Profile.new(user_phone_no: 'not a number')
    new_profile.should have(2).error_on(:user_phone_no)
  end

  it 'Should have a phone number thats a number and 10 digits' do
    new_profile = Profile.new(user_phone_no: '12345')
    new_profile.should have(1).error_on(:user_phone_no)
  end

  it 'Should increase the count by 1 on create ' do
    new_profile = Profile.new(user_first_name: 'Sagar', user_last_name: 'Bhagwan', user_phone_no: '9637396836', gender: 'M', DoB: Date.today)
    new_profile.save
    expect(Profile.count).to eq 1
  end

  # it 'Should increase the count by 1 on create ' do
  #   new_profile = create(:profile)
  #   new_profile.save
  #   expect(Profile.count).to eq 1
  # end

  # Short hand
  # it { should validate_presence_of(:user_phone_no) }

  # Model methods

  it 'should return users intitals ' do
    new_profile = Profile.new(user_first_name: :Siddhartha, user_last_name: :Bhagwan, DoB: Date.today, gender: :M, user_phone_no: '9637396836')
    new_profile.chat_name.should == 'SB'
  end

  it 'should return the sms updates status as false by default ' do
    new_profile = Profile.new(user_first_name: :Siddhartha, user_last_name: :Bhagwan, DoB: Date.today, gender: :M, user_phone_no: '9637396836')
    new_profile.sms_updates.should == 'No'
  end

  # Assocations

  it 'Should belong to a user' do
    user_association = Profile.reflect_on_association(:user)
    user_association.macro.should == :belongs_to
  end

end
