require 'test_helper'

class TsControllerTest < ActionController::TestCase
  test "should get get_input" do
    get :get_input
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
