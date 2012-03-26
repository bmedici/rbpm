require 'test_helper'

class WorkersControllerTest < ActionController::TestCase
  setup do
    @worker = workers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create worker" do
    assert_difference('Worker.count') do
      post :create, :worker => @worker.attributes
    end

    assert_redirected_to worker_path(assigns(:worker))
  end

  test "should show worker" do
    get :show, :id => @worker.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @worker.to_param
    assert_response :success
  end

  test "should update worker" do
    put :update, :id => @worker.to_param, :worker => @worker.attributes
    assert_redirected_to worker_path(assigns(:worker))
  end

  test "should destroy worker" do
    assert_difference('Worker.count', -1) do
      delete :destroy, :id => @worker.to_param
    end

    assert_redirected_to workers_path
  end
end
