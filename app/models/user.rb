class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable
  has_many :ifss, class_name: :IteratedFunctionSystem, foreign_key: :user_id, dependent: :destroy
  def self.find_for_vk_oauth access_token
    p access_token.extra.raw_info
    if user = User.where(provider: 'vkontakte', url: access_token.info.urls.Vkontakte).first
      user
    else
      password = Devise.friendly_token
      User.create! password: password, provider: :vkontakte, url: access_token.info.urls.Vkontakte, email: nil, password_confirmation: password
    end
  end
  def self.find_for_twitter_oauth access_token
    if user = User.where(provider: 'twitter', url: access_token.info.urls.Twitter).first
      user
    else
      password = Devise.friendly_token
      User.create! password: password, provider: :twitter, url: access_token.info.urls.Twitter, email: nil, password_confirmation: password
    end
  end
end
