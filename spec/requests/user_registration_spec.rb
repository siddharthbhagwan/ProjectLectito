require 'spec_helper'

describe 'user registration' do
  it 'allows new users to register with an email address and password' do
    visit '/users/sign_up'

    fill_in 'Email',                 with: 'sidunderscoresss@gmail.com',  match: :first
    fill_in 'Password',              with: 'password', match: :first
    fill_in 'Confirm Password',      with: 'password'

    click_button 'Sign up'

    page.should have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account ')
    
  end
end
