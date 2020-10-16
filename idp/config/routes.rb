Rails.application.routes.draw do
  root to: 'home#index'
  
  get 'home/index'
  devise_for :users

  get '/auth/sso/jwt/login', to: 'jwt#new'
  post '/auth/sso/jwt/login', to: 'jwt#create'
  match '/auth/sso/jwt/logout', to: 'jwt#logout', via: [:get, :post, :delete]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Tmp route for tests
  post '/', to: 'home#post'
end
