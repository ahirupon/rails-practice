module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    if session[:user_id] # userはログイン中か？
      @current_user ||= User.find_by(id: session[:user_id]) # @current_userがtrueの場合User.find_byが実行
    end
  end

  # ユーザーがログインしてればtrueを返す
  def logged_in?
    !current_user.nil? # current_userがnilでなかったらtrue
  end

  # 現在のユーザーをログアウト
  # current_userがnilの場合即座にルートパスにリダイレクトするので平気
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
