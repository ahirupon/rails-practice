class SessionsController < ApplicationController
  def new; end

  def create
    @user = User.find_by(email: params[:session][:email].downcase) # Userのemailは小文字で保存されている、ので入力されたものを小文字し、比較する。
    if @user && @user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user) # チェックボックスに入れると1、ないと0。
      redirect_to @user # = user_url(user)
    else
      # エラーメッセージを作成
      # flash[:danger]で設定したメッセージは自動的に表示されます。 .nowでその後のリクエストが発生したら消去される
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
