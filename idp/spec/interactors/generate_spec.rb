# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'
require 'generate_token'

RSpec.describe GenerateToken do
  fixtures :users
  it 'generates token when private key is present' do
    expect(GenerateToken.call(users(:test)).success?).to eq true
  end

  # it 'fails without private key' do
  #   expect(GenerateToken.call(users(:test)).failure).to eq :private_key_not_found
  # end

  # it 'fails with invalid private key file' do
  #   expect(GenerateToken.call(users(:test)).failure).to eq :RSA_error
  # end
end
