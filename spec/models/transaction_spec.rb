require 'spec_helper'

# 4 tests

describe Transaction do
  
  it 'Should have a status ' do
    new_transaction = Transaction.new(status: '')
    new_transaction.should have(1).error_on(:status)
  end

  # Associations

  it 'Should have many chats ' do
    chat_association = Transaction.reflect_on_association(:chats)
    chat_association.macro.should == :has_many
  end

  it 'Should belong to a borrower thorough user class ' do
    chat_association = Transaction.reflect_on_association(:borrower)
    chat_association.macro.should == :belongs_to
    chat_association.options[:class_name].should == 'User'
  end

  it 'Should belong to a lender thorough user class ' do
    chat_association = Transaction.reflect_on_association(:lender)
    chat_association.macro.should == :belongs_to
    chat_association.options[:class_name].should == 'User'
  end

end
