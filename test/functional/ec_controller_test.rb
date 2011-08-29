require 'test_helper'

class EcControllerTest < ActionController::TestCase
  test "should get begin" do
    get :begin
    assert_response :success
  end

  test "should get buy" do
    get :buy
    assert_response :success
  end

  test "should get ecdetails" do
    get :ecdetails
    assert_response :success
  end

  test "should get thanks" do
    get :thanks
    assert_response :success
  end

end
