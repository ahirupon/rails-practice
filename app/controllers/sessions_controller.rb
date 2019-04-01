class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase) # Userのemailは小文字で保存されている、ので入力されたものを小文字し、比較する。
    if user && user.authenticate(params[:session][:password])
      # アカウントが有効か？
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message  = 'Account not activated. '
        message += 'Check your email for the activation link.'
        flash[:warning] = message
        redirect_to root_url
      end
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
