require 'spec_helper'

# 1 tests

describe Transaction do
  
  it 'Should have a status ' do
    new_transaction = Transaction.new(status: '')
    new_transaction.should have(1).error_on(:status)
  end

end