class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable, :validatable
  has_many :ifss, class_name: :IteratedFunctionSystem, foreign_key: :user_id, dependent: :destroy

  has_many :ifs_chains, class_name: :IfsChain, foreign_key: :user_id, dependent: :destroy
  has_many :fractals, class_name: :Fractal, foreign_key: :user_id, dependent: :destroy
  has_many :likes
  #_validators.reject!{ |key, _| key == :email }
  def email_required?
    false
  end

  validates :email, uniqueness: { case_sensitive: false }, unless: 'email.nil?'
  validates :url,   uniqueness: {scope: :provider}, if: 'email.blank?'
  validates :url,   presence: true, if: 'email.blank?'
  validates :name,  length: {maximum: 100}
  validates :email,  length: {maximum: 150}

  def self.find_for_tumblr_oauth access_token
    if user = User.where(provider: 'tumblr', url: access_token.uid).first
      user
    else
      password = Devise.friendly_token
      User.create! password: password, provider: :tumblr, url: access_token.uid, email: nil, password_confirmation: password
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
