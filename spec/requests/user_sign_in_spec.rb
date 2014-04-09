require 'spec_helper'

describe 'user sign in' do
  it 'allows users to sign in after they have registered' do

    visit '/'

    click_button 'Sign In', match: :first

    fill_in 'Email',    with: 'sidunderscoresss@gmail.com'
    fill_in 'Password', with: 'password'

    page.find('.nfp').click

    $stderr.puts '++++'
    page.should have_content('Signed in successfully')
  end
end
