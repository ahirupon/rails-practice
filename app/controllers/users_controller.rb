# @userを定義 params[:id]はユーザーidに入れ替わる = User.find(1)
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
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
      log_in @user
      flash[:success] = 'Welcome to Sample App!!'
      redirect_to @user # = redirect_to user_url(@user)
    else
      # /newにリダイレクト
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
# "user" => { "name" => "Foo Bar",
#            "email" => "foo@invalid",
#            "password" => "[FILTERED]",
#           "password_confirmation" => "[FILTERED]"
#          }
# ↑これはuserコントローラーによりparamsに渡される
