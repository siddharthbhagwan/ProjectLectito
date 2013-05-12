require 'test_helper'

class DeviseControllerTest < ActionController::TestCase
  test "should get User" do
    get :User
    assert_response :success
  end

end
