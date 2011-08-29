require 'test_helper'

class MasspayControllerTest < ActionController::TestCase
  test "should get mass_pay" do
    get :mass_pay
    assert_response :success
  end

  test "should get thanks" do
    get :thanks
    assert_response :success
  end

end
