require 'test_helper'

class SystemsControllerTest < ActionController::TestCase
  setup do
    @system = systems(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:systems)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create system" do
    assert_difference('System.count') do
      post :create, :system => @system.attributes
    end

    assert_redirected_to system_path(assigns(:system))
  end

  test "should show system" do
    get :show, :id => @system.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @system.to_param
    assert_response :success
  end

  test "should update system" do
    put :update, :id => @system.to_param, :system => @system.attributes
    assert_redirected_to system_path(assigns(:system))
  end

  test "should destroy system" do
    assert_difference('System.count', -1) do
      delete :destroy, :id => @system.to_param
    end

    assert_redirected_to systems_path
  end
end
