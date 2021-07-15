# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidateToken do
  subject(:interactor_call) { described_class.call token }

  include_context 'tokens'

  context 'when token is good' do
    let(:token) { valid }

    it { is_expected.to be_success }
  end

  context 'when token is expired' do
    let(:token) { expired }

    it { expect(interactor_call.failure).to eq :invalid_token }
  end

  context 'when token is invalid' do
    let(:token) { invalid }

    it { expect(interactor_call.failure).to eq :invalid_token }
  end

  context 'when token has no iss' do
    let(:token) { no_iss }

    it { expect(interactor_call.failure).to eq :no_iss }
  end

  context 'when token has wrong iss' do
    let(:token) { wrong_iss }

    it { expect(interactor_call.failure).to eq :public_key_not_found }
  end
end
