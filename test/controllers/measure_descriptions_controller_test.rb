require 'test_helper'

class MeasureDescriptionsControllerTest < ActionController::TestCase
  setup do
    @measure_description = measure_descriptions(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:measure_descriptions)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create measure_description' do
    assert_difference('MeasureDescription.count') do
      post :create, measure_description: {}
    end

    assert_redirected_to measure_description_path(assigns(:measure_description))
  end

  test 'should show measure_description' do
    get :show, id: @measure_description
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @measure_description
    assert_response :success
  end

  test 'should update measure_description' do
    patch :update, id: @measure_description, measure_description: {}
    assert_redirected_to measure_description_path(assigns(:measure_description))
  end

  test 'should destroy measure_description' do
    assert_difference('MeasureDescription.count', -1) do
      delete :destroy, id: @measure_description
    end

    assert_redirected_to measure_descriptions_path
  end
end
