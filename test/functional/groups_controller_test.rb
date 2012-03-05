require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    @group = groups(:one)
    session[:user_id] = @group.user.id
  end

  test "should get index" do
    session[:user_id] = @group.user.id
    
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
    assert_equal  2, assigns(:groups).count, "Number of groups should be equal to two"
  end

  test "should get index with only the groups owned by the user" do
    session[:user_id] = groups(:three).user.id
    
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
    assert_equal 1, assigns(:groups).count,"Number of groups should be equal to one"
    assert_equal "Hugo_Reyes", assigns(:groups).first.name, "Name other then Hugo_Reyes is not expected"
  end

  test "should get index but not show any groups" do
    session[:user_id] = users(:kate_austen).id
    get :index
    assert_response :success
    assert_empty assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post :create, group: @group.attributes
    end

    assert_equal "Group 'Coral Arch' was successfully created.",flash[:notice]
    assert_redirected_to groups_path
  end

  test "should show group" do
    get :show, id: @group.to_param
    assert_response :success
  end

  test "should redirect index if user tries to see a group the user doesnt own" do
    session[:user_id] = users(:john_locke).id
    get :show, id: @group.to_param

    assert_equal "Group was not found", flash[:error]
    assert_redirected_to groups_path
  end

  test "should get edit" do
    get :edit, id: @group.to_param
    assert_response :success
  end

  test "should redirect index if user tries to edit a group the user doesnt own" do
    session[:user_id] = users(:john_locke).id
    get :edit, id: @group.to_param

    assert_equal "Group was not found", flash[:error]
    assert_redirected_to groups_path
  end

  test "should update group" do    
    @group.name = "Charlie"
    put :update, id: @group.to_param, group: @group.attributes
    
    assert_equal "Charlie", Group.find(@group.id).name, " Name Should have been equal to charlie "
    assert_equal "Group 'Charlie' was successfully updated.",flash[:notice]
    assert_redirected_to groups_path
  end

  test "should redirect index if user tries to update an invalid group" do
    session[:user_id] = users(:john_locke).id
    @group.name = "Charlie"
    put :update, id: @group.to_param, group: @group.attributes

    assert_equal "Coral Arch", Group.find_by_id(groups(:one)).name, "Name should not have been updated"
    assert_equal "Group was not found", flash[:error], "Flash Message not set to 'Group was not found'"
    assert_redirected_to groups_path
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, id: @group.to_param
    end

    assert_nil Group.find_by_id(groups(:one).id)
    assert_redirected_to groups_path
  end

  test "should redirect index if user tries to destroy a group the user doesnt own" do
    session[:user_id] = users(:john_locke).id
    assert_difference('Group.count', 0) do
      delete :destroy, id: @group.to_param
    end
    assert_equal "Group was not found", flash[:error]
    assert_redirected_to groups_path
  end

  test "should add the user to the group on click of the adduser link" do
    session[:user_id] = users(:kate_austen).id
    get :adduser, :code => @group.code
    assert_equal "You have been added to '#{@group.name}'", flash[:notice]
    assert_equal @group.users.count, 2, "There shud be two members in this group"
    assert_redirected_to groups_path
  end
  
  test "should redirect to index on click on adduser with invalid code" do
    session[:user_id] = users(:kate_austen).id
    get :adduser, :code => "1234"
    
    assert_equal "Cannot complete your request. Attempt to access an Invalid page", flash[:error]
    assert_equal @group.users.count, 1, "There shud be a sole member in this group"
    assert_redirected_to groups_path
  end



end
