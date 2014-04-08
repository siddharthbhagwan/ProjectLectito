require 'spec_helper'

# 2 tests

describe Inventory do
  
  it 'Should have a status ' do
    new_inventory = Inventory.new(status: '')
    new_inventory.should have(1).error_on(:status)
  end

  it 'Should have an available in city ' do
    new_inventory = Inventory.new(available_in_city: '')
    new_inventory.should have(1).error_on(:available_in_city)
  end

end