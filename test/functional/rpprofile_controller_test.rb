require 'test_helper'

class RpprofileControllerTest < ActionController::TestCase
  test "should get begin" do
    get :begin
    assert_response :success
  end

  test "should get thanks" do
    get :thanks
    assert_response :success
  end

end
