require 'test_helper'

class WebserviceControllerTest < ActionController::TestCase
  test "should get gethour" do
    get :gethour
    assert_response :success
  end

  test "should get wait" do
    get :wait
    assert_response :success
  end

  test "should get encode" do
    get :encode
    assert_response :success
  end

  test "should get checksum" do
    get :checksum
    assert_response :success
  end

end
