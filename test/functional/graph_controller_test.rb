require 'test_helper'

class GraphControllerTest < ActionController::TestCase
  test "should get workflow" do
    get :workflow
    assert_response :success
  end

end
