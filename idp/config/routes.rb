Rails.application.routes.draw do
  root to: 'jwt#index'
  
  get 'jwt/index'
  
  devise_for :users

  get '/auth/sso/jwt/login', to: 'jwt#new'
  post '/auth/sso/jwt/login', to: 'jwt#create'
  match '/auth/sso/jwt/logout', to: 'jwt#logout', via: [:get, :post, :delete]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
