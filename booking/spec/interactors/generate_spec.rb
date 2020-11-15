# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

RSpec.describe GenerateToken do
  it 'generates token when there is a private key and callback_url' do
    result = GenerateToken.call 'callback_url'
    expect(result.success?).to eq true
  end

  it 'generates token when there is a private key, but no callback_url' do
    result = GenerateToken.call 
    expect(result.success?).to eq true
  end

  # it 'fails without private key' do
  #   result = GenerateToken.call 
  #   expect(result.failure).to eq :private_key_not_found
  # end

  # it 'fails with invalid private key' do
  #   result = GenerateToken.call 
  #   expect(result.failure).to eq :RSA_error
  # end
end
