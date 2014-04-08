require 'spec_helper'

# 4 tests

describe Chat do
  
  it 'Should have a from user' do
    new_chat = Chat.new(from_user: '')
    new_chat.should have(1).error_on(:from_user)
  end

  it 'Should have a from user' do
    new_chat = Chat.new(body: '')
    new_chat.should have(1).error_on(:body)
  end

end