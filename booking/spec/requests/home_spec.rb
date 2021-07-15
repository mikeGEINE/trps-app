# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

RSpec.describe 'Home' do
  include_context 'tokens'
  
  it 'accepts requests when token is set' do
    cookies[:token] = valid_idp
    get '/'
    expect(response).to have_http_status(200)
  end

  it 'denies requests with invalid token' do
    cookies[:token] = invalid_idp
    get '/'
    expect(response).not_to have_http_status(200)
  end

  it 'denies requests without token' do
    cookies.delete :token
    get '/'
    expect(response).not_to have_http_status(200)
  end
end
