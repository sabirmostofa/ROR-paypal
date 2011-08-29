require 'test_helper'

class WpproControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get error" do
    get :error
    assert_response :success
  end

  test "should get exception" do
    get :exception
    assert_response :success
  end

end
