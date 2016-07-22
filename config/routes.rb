Fractalator::Application.routes.draw do
  Rails.application.routes.default_url_options[:host] = 'fractalator.com'

  %i[fractals iterated_function_systems ifs_chains].each do |controller|
    resources controller do
      member do
        get 'fork' => :fork, as: :fork
        get 'next' => :next, as: :next
        get 'prev' => :prev, as: :prev
      end
      collection do
        get 'index/:id' => :index, as: :index
        get ':id/like' => :like, as: :like, defaults: { :format => 'json' }
      end
    end
  end

  post "main/signIn"
  post "main/signUp"
  post "main/set_name"
  devise_for :users,  controllers: { :omniauth_callbacks => "users/omniauth_callbacks", passwords: "passwords" }
  get "main/index"
  get "main/curves"
  root to: "main#index"
end
