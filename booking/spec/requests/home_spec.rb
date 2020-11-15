# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

RSpec.describe 'Home' do
  valid = 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJpZHAiLCJleHAiOjI2MDU0NDQ5NDQsInJlZnJlc2hfdG9rZW4iOmZhbHNlLCJlbWFpbCI6InRlc3RAYm1zdHUucnUifQ.AB-HiXUZ6w8HcODh8Geys_qLK6pKEqJE4tuujRzMC_LH1TbapReHAgI6EhhuiqWtp35tj58ijWdmzgj3TGD25-fT1vm_uqwyrTcZY1Kg9vPcy6CM6Kocojp-3TZbt36lAbVEynRDUQjMz0LhcC1Hd_yNtNgtFHqfH3OsOZKDLzvb8ck_lhYIrV40h0BIPGIP1S4PuciJWePgkpIXnk3j1tvjFnRT-jJ0vYR1cEqes67WMi-uEyDkAeNt_A9k9i-pbkVNzpbyAHZtMzLdojF5g_XRtK2sFRhqL5h15Z99DNluUlAGDkwcTl9BgzASTKNI6_QpLdMgUUc_JfWvvj0P6A'
  invalid = 'eyJhbGciOiJSUI1NiJ9.eyJpc3MiOiJpZHAiLCJleHAiOjI2MDU0NDQ5NDQsInJlZnJlc2hfdG9rWiOmZhbHNlLCJlbWFpbCI6InRlc3AYm1zdHUucnUifQ.AB-HiXUZ6w8HcODh8Geys_qLK6pKEqJEtuujRzMC_LH1TbapReHAgI6EhhuiqWtp35tj58ijWdmzgj3TGD25-fT1vm_uqwyrTcZY1Kg9vPcy6CM6Kocojp-3TZbt36lAbVEynRDUQjMz0LhcC1Hd_yNtNgtFHqfH3OsOZKDLzvb8ck_lhYIrV40h0BIPGIP1S4PuciJWePgkpIXnk3j1tvjFnRT-jJ0vYR1cEqes67WMi-uEyDkAeNt_A9k9i-pbkVNzpbyAHZtMzLdojF5g_XRtK2sFRhqL5h15Z99DNluUlAGDkwcTl9BgzASKNI6_QpLdMgUUc_JfWvvj0P'
  
  it 'accepts requests when token is set' do
    cookies[:token] = valid
    get '/'
    expect(response).to have_http_status(200)
  end

  it 'denies requests with invalid token' do
    cookies[:token] = invalid
    get '/'
    expect(response).not_to have_http_status(200)
  end

  it 'denies requests without token' do
    cookies.delete :token
    get '/'
    expect(response).not_to have_http_status(200)
  end
end
