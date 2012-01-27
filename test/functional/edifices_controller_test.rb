require 'test_helper'

class EdificesControllerTest < ActionController::TestCase
  setup do
    @edifice = edifices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:edifices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create edifice" do
    assert_difference('Edifice.count') do
      post :create, :edifice => @edifice.attributes
    end

    assert_redirected_to edifice_path(assigns(:edifice))
  end

  test "should show edifice" do
    get :show, :id => @edifice.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @edifice.to_param
    assert_response :success
  end

  test "should update edifice" do
    put :update, :id => @edifice.to_param, :edifice => @edifice.attributes
    assert_redirected_to edifice_path(assigns(:edifice))
  end

  test "should destroy edifice" do
    assert_difference('Edifice.count', -1) do
      delete :destroy, :id => @edifice.to_param
    end

    assert_redirected_to edifices_path
  end
end
