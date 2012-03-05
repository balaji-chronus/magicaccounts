require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    
    assert_nil session[:user_id]
    assert_equal "You have been logged out", flash[:notice]
    assert_redirected_to login_url
  end

end
