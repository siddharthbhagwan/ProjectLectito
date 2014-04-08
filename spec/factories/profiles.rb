FactoryGirl.define do 
  factory :profile do |f|
    user_first_name 'Siddhartha'
    user_last_name 'Bhagwan'
    user_phone_no '9637396836'
    DoB: Date.today
    gender 'M'
  end
end
