require 'test_helper'

# users.ymlからテストユーザーを取り出し@userに代入

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'login with invalid information' do
    get login_path # ログイン用のpathを開く
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } } # テストユーザーでログイン
    assert is_logged_in? # ログインしてるか？

    assert_redirected_to @user # リダイレクト先が正しいか？
    follow_redirect! # 実際にリダイレクトページに飛ぶ　ログインパスがページにないかもチェック
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0 # login_pathリンクはページ上に0個存在するか確認
    assert_select 'a[href=?]', logout_path # logout_pathリンクを確認
    assert_select 'a[href=?]', user_path(@user) # プロフィール用リンクを確認
    delete logout_path # ログアウトする
    assert_not is_logged_in? # ログアウトしているか？
    assert_redirected_to root_url # root_urlにリダイレクトしているか？
    delete logout_path # 二番目のウィンドウでログアウトをクリックするのをシュミレート
    follow_redirect! # 実際にリダイレクトページに飛ぶ　ログインパスがページにないかもチェック
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,      count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end
  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_equal @user.email, assigns(:user).email
  end

  test 'login without remembering' do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
