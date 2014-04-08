require 'spec_helper'

# 1 tests

describe User do
  
  it 'Should have an email ' do
    new_user = User.new(email: '')
    new_user.should have(1).error_on(:email)
  end

end