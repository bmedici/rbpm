require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  setup do
    @link = links(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:links)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create link" do
    assert_difference('Link.count') do
      post :create, :link => @link.attributes
    end

    assert_redirected_to link_path(assigns(:link))
  end

  test "should show link" do
    get :show, :id => @link.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @link.to_param
    assert_response :success
  end

  test "should update link" do
    put :update, :id => @link.to_param, :link => @link.attributes
    assert_redirected_to link_path(assigns(:link))
  end

  test "should destroy link" do
    assert_difference('Link.count', -1) do
      delete :destroy, :id => @link.to_param
    end

    assert_redirected_to links_path
  end
end
