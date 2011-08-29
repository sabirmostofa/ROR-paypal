require 'test_helper'

class DovoidControllerTest < ActionController::TestCase
  test "should get get_input" do
    get :get_input
    assert_response :success
  end

  test "should get thanks" do
    get :thanks
    assert_response :success
  end

end
