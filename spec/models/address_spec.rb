require 'spec_helper'

# 8 tests

describe Address do

  it 'Should have a line 1' do
    new_address = Address.new(address_line1: '')
    new_address.should have(1).error_on(:address_line1)
  end

  it 'Should have an pin' do
    new_address = Address.new(pin: '')
    new_address.should have(3).error_on(:pin)
  end

  it 'Should have an pin which should be a number' do
    new_address = Address.new(pin: 'not a number')
    new_address.should have(2).error_on(:pin)
  end

  it 'Should have an pin which should be a number less than 999999 (not more than 6 digits)' do
    new_address = Address.new(pin: 1231231)
    new_address.should have(1).error_on(:pin)
  end

  it 'Should have an pin which should be a number grater than 100000 (not less than 6 digits)' do
    new_address = Address.new(pin: 123)
    new_address.should have(1).error_on(:pin)
  end

  it 'Should increase the count by 1 on create ' do
    new_address = Address.new(address_line1: 'Iris L 902', pin: '411028')
    new_address.save
    expect(Address.count).to eq 1
  end

  # Associations

  it 'Should belong to a user ' do
    user_association = Address.reflect_on_association(:user)
    user_association.macro.should == :belongs_to
  end

  it 'Should have many inventories through a foreign key ' do
    inventories_association = Address.reflect_on_association(:inventories)
    inventories_association.macro.should == :has_many
    inventories_association.options[:foreign_key].should == :available_in_city
  end

end
