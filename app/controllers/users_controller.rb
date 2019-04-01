# @userを定義 params[:id]はユーザーidに入れ替わる = User.find(1)
class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update delete]
  before_action :correct_user,   only: %i[edit update]
  before_action :admin_user,     only: :destroy
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    # よくわからないことがあったらdebuggerで調べてみる
    # debugger
  end

  # /signup
  def new
    @user = User.new
  end

  def create
    # debugger
    @user = User.new(user_params)
    # @user = User.new(name: "Foo Bar", email: "foo@invalid",
    #             password: "foo", password_confirmation: "bar")
    if @user.save
      @user.send_activation_email
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      # /newにリダイレクト
      render 'new'
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      # 更新に成功した場合を扱う
      flash[:success] = 'profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # ログインを要求するメゾット
  def logged_in_user
    unless logged_in? # logged_inがtrueでないなら
      store_location # アクセスしようとしたurlを覚えておくメゾット
      flash[:danger] = 'Please log in'
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user) # @userがurlに入力されたuseridでなければroot_urlにリダイレクト
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # beforeアクション

  # beforeフィルター
  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'Please log in.'
      redirect_to login_url
    end
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url) unless current_user.try(:admin?)
  end

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
