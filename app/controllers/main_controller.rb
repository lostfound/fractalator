class MainController < ApplicationController
  before_action :check_signin, only: [:ifs]
  def index
  end

  def ifs
  end

  def signIn
    if user_signed_in?
      return redirect_to main_index_path
    end
    user = User.find_by_email(params[:user][:email])
    if user and user.valid_password?(params[:user][:password])
      sign_in user
      return redirect_to main_index_path
    end
    @sin_user = User.new(email: params[:user][:email])
    render 'index'
  end

  def signUp
    if user_signed_in?
      return redirect_to main_index_path
    end
    user = User.create sign_up_params
    if user.valid?
      sign_in user
      return redirect_to main_index_path
    end
    @sup_user = user
    render 'index'
  end
  def set_name
    if user_signed_in? and params[:name]
      current_user.update(name: params[:name])

    end
    render "index"
  end
private
  def sign_up_params
    params.require(:user).permit :email, :password, :password_confirmation
  end
  def check_signin
    redirect_to main_index_path unless user_signed_in?
  end
  
end