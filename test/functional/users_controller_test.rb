require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    @user.password = "123456"
    @user.password_confirmation = "123456"

    current_user = @user.id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    @user.name = "hugo reyes"
    @user.salt = "698396597386400.4908656478833584"
    @user.hashed_password = "13166a8f41fe58f02b066bda8a45dd4226fdbb6938a85d3efd1bc88d8d09523d"
    assert_difference('User.count') do
      post :create, user: @user.attributes
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user.to_param
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "should get edit" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  test "should update user" do    
    @user.name = "charlie"
    put :update, id: @user.to_param, user: @user.attributes
    assert_redirected_to transactions_path
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user.to_param
    end

    assert_redirected_to users_path
  end
end
