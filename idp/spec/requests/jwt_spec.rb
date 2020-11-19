# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Jwt', type: :request do
  include_context 'tokens'
  
  it 'shows index in any case' do
    get jwt_index_path
    expect(response).to have_http_status(:ok)
  end

  describe 'GET /auth/sso/jwt/login' do
    it 'redirects to login form with a token' do
      get '/auth/sso/jwt/login', params: { token: login }
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it 'does not load #new without token' do
      get '/auth/sso/jwt/login'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /auth/sso/jwt/logout' do
    it 'logouts user with token' do
      get '/auth/sso/jwt/logout', params: {token: logout}
      expect(response).to have_http_status(:ok)
    end

    it 'does not load #logout without token' do
      get '/auth/sso/jwt/logout'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /auth/sso/jwt/login' do
    it 'logins user with correct input' do
      post '/auth/sso/jwt/login', params: { token: login, user: correct_user, commit: "Log in"}
      expect(response).to have_http_status(:ok)
    end

    it 'rerenders login form for user with incorrect login' do
      post '/auth/sso/jwt/login', params: { token: login, user: incorrect_login, commit: "Log in"}
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it 'rerenders login form for user with incorrect password' do
      post '/auth/sso/jwt/login', params: { token: login, user: incorrect_password, commit: "Log in"}
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end

end
