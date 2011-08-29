require 'test_helper'

class BilloutamtControllerTest < ActionController::TestCase
  test "should get begin" do
    get :begin
    assert_response :success
  end

  test "should get billdetails" do
    get :billdetails
    assert_response :success
  end

end
