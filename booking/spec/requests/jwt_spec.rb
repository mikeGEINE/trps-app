# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Jwt' do
  include_context 'tokens'

  it 'renders index page' do
    get '/jwt/index'
    expect(response).to have_http_status(:ok)
  end

  it 'redirects to idp login' do
    get '/jwt/login_request'
    expect(response).to have_http_status(:found)
  end

  it 'redirects to idp logout' do
    get '/jwt/logout_request'
    expect(response).to have_http_status(:found)
  end

  it 'successfully recieves login response from idp' do
    post "/jwt/acs?token=#{valid_idp}"
    expect(response).to have_http_status(:found)
    expect(response.cookies['token'].present?).to eq true
    expect(response.cookies['was_authorized'].present?).to eq true
  end

  it 'successfully recieves logout response from idp' do
    post "/jwt/logout?token=#{valid_idp}"
    expect(response).to have_http_status(:found)
    expect(response.cookies['token'].present?).to eq false
    expect(response.cookies['was_authorized'].present?).to eq false
  end

  it 'denies login with invalid token' do
    post "/jwt/acs?token=#{invalid_idp}"
    expect(response).to have_http_status(:found)
    expect(flash[:alert].present?).to eq true
  end

  it 'denies logout with invalid token' do
    post "/jwt/logout?token=#{invalid_idp}"
    expect(response).to have_http_status(:found)
    expect(flash[:alert].present?).to eq true
  end
end
