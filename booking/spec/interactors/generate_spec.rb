# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateToken do
  context 'with private key' do
    it 'generates token when callback_url is present' do
      result = GenerateToken.call 'callback_url'
      expect(result.success?).to eq true
    end

    it 'generates token when no callback_url' do
      result = GenerateToken.call 
      expect(result.success?).to eq true
    end
  end

  context 'without private key' do
    let!(:cached_rsa_dir) { Rails.configuration.jwt[:rsa_private_dir] }
    before do
      Rails.configuration.jwt[:rsa_private_dir] = 'spec/fixtures/keys/not_exist'
    end

    after do
      Rails.configuration.jwt[:rsa_private_dir] = cached_rsa_dir
    end

    it 'fails' do
      result = GenerateToken.call 
      expect(result.failure).to eq :private_key_not_found
    end
  end
end
