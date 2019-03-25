require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test 'should get new' do
    get signup_path
    assert_response :success
    assert_select 'title', 'Sign up | Ruby on Rails Tutorial Sample App'
  end

  test 'should redirect edit when not logged_in' do
    get edit_user_path(@user)
    assert flash.any?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged_in' do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should not allow the admin attribute to be edited via the web' do # via 経由
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
      user: { password: 'password',
              password_confirmation: 'password',
              admin: true }
    }
    assert_not @other_user.admin?
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@other_user)
    patch user_path(@user), params: { users: { name: @user.name,
                                               email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    # assert_redirected_to login_url
  end

  test 'should redirect destroy when logged in as a non-admin' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
