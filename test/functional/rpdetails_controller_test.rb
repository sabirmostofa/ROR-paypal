require 'test_helper'

class RpdetailsControllerTest < ActionController::TestCase
  test "should get begin" do
    get :begin
    assert_response :success
  end

  test "should get RPdetails" do
    get :RPdetails
    assert_response :success
  end

  test "should get details" do
    get :details
    assert_response :success
  end

end
