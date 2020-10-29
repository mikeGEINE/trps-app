Rails.application.routes.draw do
  root to: 'home#index'
  
  get 'home/index'
  get 'jwt/new'
  post 'jwt/acs'
  post 'jwt/logout'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
