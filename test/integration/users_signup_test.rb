require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # user_pathに間違ったuserを追加しようとしてもuser.countは変わらないか？
  test 'invalid signup information' do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                         email: 'user@invalid',
                                         password: 'foo',
                                         password_confirmation: 'bar' } }
    end
    # users/newは再描画されているか？
    assert_template 'users/new'
    # エラーメッセージの確認
    assert_select 'div.alert', text: 'The form contains 4 errors.'
    assert_select 'ul' do
      assert_select 'li', 'Name can\'t be blank'
      assert_select 'li', 'Email is invalid'
      assert_select 'li', 'Password is too short (minimum is 6 characters)'
    end
    # signup_pathにpostされているかurlからテスト
    assert_select 'form[action="/signup"]'
  end

  test 'valid signup information' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User',
                                         email: 'user@example.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
