require 'spec_helper'

# 6 tests

describe Inventory do
  
  it 'Should have a status ' do
    new_inventory = Inventory.new(status: '')
    new_inventory.should have(1).error_on(:status)
  end

  it 'Should have an available in city ' do
    new_inventory = Inventory.new(available_in_city: '')
    new_inventory.should have(1).error_on(:available_in_city)
  end

  # Assocations

  it 'Should belong to a book ' do
    book_association = Inventory.reflect_on_association(:book)
    book_association.macro.should == :belongs_to
  end

  it 'Should belong to a user ' do
    user_association = Inventory.reflect_on_association(:user)
    user_association.macro.should == :belongs_to
  end

  it 'Should have many transactions ' do
    transaction_association = Inventory.reflect_on_association(:transactions)
    transaction_association.macro.should == :has_many
  end

  it 'Should belong to an address through a foreign key ' do
    address_association = Inventory.reflect_on_association(:address)
    address_association.macro.should == :belongs_to
    address_association.options[:foreign_key].should == :available_in_city
  end

end
