require 'test_helper'

class ManageprofileControllerTest < ActionController::TestCase
  test "should get begin" do
    get :begin
    assert_response :success
  end

  test "should get changedProfile" do
    get :changedProfile
    assert_response :success
  end

end
