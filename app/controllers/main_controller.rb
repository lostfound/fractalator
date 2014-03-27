class MainController < ApplicationController
  def index
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
private
  def sign_up_params
    params.require(:user).permit :email, :password, :password_confirmation
  end
  
end
