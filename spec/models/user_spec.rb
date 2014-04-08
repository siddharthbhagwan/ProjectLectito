require 'spec_helper'

# 6 tests

describe User do
  
  it 'Should have an email ' do
    new_user = User.new(email: '')
    new_user.should have(1).error_on(:email)
  end

  # Associations

  it 'Should have many inventories ' do
    inventories_association = User.reflect_on_association(:inventories)
    inventories_association.macro.should == :has_many
  end

  it 'Should have one profile ' do
    profile_association = User.reflect_on_association(:profile)
    profile_association.macro.should == :has_one
  end

  it 'Should have many addresses ' do
    address_association = User.reflect_on_association(:addresses)
    address_association.macro.should == :has_many
  end

  it 'Should have many transactions ' do
    transaction_association = User.reflect_on_association(:transactions)
    transaction_association.macro.should == :has_many
  end

  it 'Should have many books through inventories ' do
    user_association = User.reflect_on_association(:books)
    user_association.macro.should == :has_many
    user_association.options[:through].should == :inventories
  end

end
