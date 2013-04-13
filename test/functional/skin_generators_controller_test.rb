require 'test_helper'

class SkinGeneratorsControllerTest < ActionController::TestCase
  setup do
    @skin_generator = skin_generators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:skin_generators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create skin_generator" do
    assert_difference('SkinGenerator.count') do
      post :create, skin_generator: {  }
    end

    assert_redirected_to skin_generator_path(assigns(:skin_generator))
  end

  test "should show skin_generator" do
    get :show, id: @skin_generator
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @skin_generator
    assert_response :success
  end

  test "should update skin_generator" do
    put :update, id: @skin_generator, skin_generator: {  }
    assert_redirected_to skin_generator_path(assigns(:skin_generator))
  end

  test "should destroy skin_generator" do
    assert_difference('SkinGenerator.count', -1) do
      delete :destroy, id: @skin_generator
    end

    assert_redirected_to skin_generators_path
  end
end
