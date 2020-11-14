# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'
require 'authenticate_user'

RSpec.describe AuthenticateUser do
  fixtures :users
  it 'authenticates correct data' do
    expect(authenticate('test@bmstu.ru', 'password').success?).to eq true
  end

  it 'fails with wrong password' do
    expect(authenticate('test@bmstu.ru', 'wrong_password').failure).to eq :wrong_password
  end

  it 'fails with no user' do
    expect(authenticate('test15@bmstu.ru', 'password').failure).to eq :user_not_found
  end

  def authenticate(email, password)
    AuthenticateUser.call({email: email, password: password})
  end
end
