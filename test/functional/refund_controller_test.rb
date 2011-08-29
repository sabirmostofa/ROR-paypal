require 'test_helper'

class RefundControllerTest < ActionController::TestCase
  test "should get get_input" do
    get :get_input
    assert_response :success
  end

  test "should get status" do
    get :status
    assert_response :success
  end

end
