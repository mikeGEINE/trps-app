# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractEmail do
  include_context 'tokens'

  it 'extracts email from decoded token' do
    expect(ExtractEmail.call(decode(email)).success?).to eq true
  end

  it 'fails when there is no email' do
    expect(ExtractEmail.call(decode(no_email)).failure).to eq :no_email
  end

  def decode(token)
    ValidateToken.call(token).success
  end
end
