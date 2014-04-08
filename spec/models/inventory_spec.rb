require 'spec_helper'

# 4 tests

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

end
