Rails.application.routes.draw do
  root to: 'home#index'
  
  get 'home/index'
  get 'jwt/login_request'
  get 'jwt/logout_request'
  post 'jwt/acs'
  post 'jwt/logout'
  get 'jwt/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
