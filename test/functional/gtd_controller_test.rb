require 'test_helper'

class GtdControllerTest < ActionController::TestCase
  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get transaction_details" do
    get :transaction_details
    assert_response :success
  end

end
