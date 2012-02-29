require 'test_helper'

class ActionsControllerTest < ActionController::TestCase
  setup do
    @action = actions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create action" do
    assert_difference('Action.count') do
      post :create, :action => @action.attributes
    end

    assert_redirected_to action_path(assigns(:action))
  end

  test "should show action" do
    get :show, :id => @action.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @action.to_param
    assert_response :success
  end

  test "should update action" do
    put :update, :id => @action.to_param, :action => @action.attributes
    assert_redirected_to action_path(assigns(:action))
  end

  test "should destroy action" do
    assert_difference('Action.count', -1) do
      delete :destroy, :id => @action.to_param
    end

    assert_redirected_to actions_path
  end
end
