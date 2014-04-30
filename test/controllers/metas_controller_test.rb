require 'test_helper'

class MetasControllerTest < ActionController::TestCase
  setup do
    @meta = metas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:metas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meta" do
    assert_difference('Metas.count') do
      post :create, meta: {  }
    end

    assert_redirected_to meta_path(assigns(:meta))
  end

  test "should show meta" do
    get :show, id: @meta
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @meta
    assert_response :success
  end

  test "should update meta" do
    patch :update, id: @meta, meta: {  }
    assert_redirected_to meta_path(assigns(:meta))
  end

  test "should destroy meta" do
    assert_difference('Metas.count', -1) do
      delete :destroy, id: @meta
    end

    assert_redirected_to metas_index_path
  end
end
