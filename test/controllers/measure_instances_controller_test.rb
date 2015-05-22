require 'test_helper'

class MeasureInstancesControllerTest < ActionController::TestCase
  setup do
    @measure_instance = measure_instances(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:measure_instances)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create measure_instance' do
    assert_difference('MeasureInstance.count') do
      post :create, measure_instance: {}
    end

    assert_redirected_to measure_instance_path(assigns(:measure_instance))
  end

  test 'should show measure_instance' do
    get :show, id: @measure_instance
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @measure_instance
    assert_response :success
  end

  test 'should update measure_instance' do
    patch :update, id: @measure_instance, measure_instance: {}
    assert_redirected_to measure_instance_path(assigns(:measure_instance))
  end

  test 'should destroy measure_instance' do
    assert_difference('MeasureInstance.count', -1) do
      delete :destroy, id: @measure_instance
    end

    assert_redirected_to measure_instances_path
  end
end
