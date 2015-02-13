class Users::OmniauthCallbacksController < ApplicationController
  def vkontakte
    user=User.find_for_vk_oauth request.env["omniauth.auth"]
    unless user.nil?
      sign_in user
    end
    redirect_to root_path
  end
  def twitter
    user=User.find_for_twitter_oauth request.env["omniauth.auth"]
    unless user.nil?
      sign_in user
    end
    redirect_to root_path
  end
end
