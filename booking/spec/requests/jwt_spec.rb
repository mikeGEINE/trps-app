# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

RSpec.describe 'Jwt' do
  valid = 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJpZHAiLCJleHAiOjI2MDU0NDQ5NDQsInJlZnJlc2hfdG9rZW4iOmZhbHNlLCJlbWFpbCI6InRlc3RAYm1zdHUucnUifQ.AB-HiXUZ6w8HcODh8Geys_qLK6pKEqJE4tuujRzMC_LH1TbapReHAgI6EhhuiqWtp35tj58ijWdmzgj3TGD25-fT1vm_uqwyrTcZY1Kg9vPcy6CM6Kocojp-3TZbt36lAbVEynRDUQjMz0LhcC1Hd_yNtNgtFHqfH3OsOZKDLzvb8ck_lhYIrV40h0BIPGIP1S4PuciJWePgkpIXnk3j1tvjFnRT-jJ0vYR1cEqes67WMi-uEyDkAeNt_A9k9i-pbkVNzpbyAHZtMzLdojF5g_XRtK2sFRhqL5h15Z99DNluUlAGDkwcTl9BgzASTKNI6_QpLdMgUUc_JfWvvj0P6A'
  invalid = 'eyJhbGciOiJSUI1NiJ9.eyJpc3MiOiJpZHAiLCJleHAiOjI2MDU0NDQ5NDQsInJlZnJlc2hfdG9rWiOmZhbHNlLCJlbWFpbCI6InRlc3AYm1zdHUucnUifQ.AB-HiXUZ6w8HcODh8Geys_qLK6pKEqJEtuujRzMC_LH1TbapReHAgI6EhhuiqWtp35tj58ijWdmzgj3TGD25-fT1vm_uqwyrTcZY1Kg9vPcy6CM6Kocojp-3TZbt36lAbVEynRDUQjMz0LhcC1Hd_yNtNgtFHqfH3OsOZKDLzvb8ck_lhYIrV40h0BIPGIP1S4PuciJWePgkpIXnk3j1tvjFnRT-jJ0vYR1cEqes67WMi-uEyDkAeNt_A9k9i-pbkVNzpbyAHZtMzLdojF5g_XRtK2sFRhqL5h15Z99DNluUlAGDkwcTl9BgzASKNI6_QpLdMgUUc_JfWvvj0P'

  it 'renders index page' do
    get '/jwt/index'
    expect(response).to have_http_status(200)
  end

  it 'redirects to idp login' do
    get '/jwt/login_request'
    expect(response).to have_http_status(302)
  end

  it 'redirects to idp logout' do
    get '/jwt/logout_request'
    expect(response).to have_http_status(302)
  end

  it 'successfully recieves login response from idp' do
    post "/jwt/acs?token=#{valid}"
    expect(response).to have_http_status(302)
    expect(response.cookies['token'].present?).to eq true
    expect(response.cookies['was_authorized'].present?).to eq true
  end

  it 'successfully recieves logout response from idp' do
    post "/jwt/logout?token=#{valid}"
    expect(response).to have_http_status(302)
    expect(response.cookies['token'].present?).to eq false
    expect(response.cookies['was_authorized'].present?).to eq false
  end

  it 'denies login with invalid token' do
    post "/jwt/acs?token=#{invalid}"
    expect(response).to have_http_status(302)
    expect(flash[:alert].present?).to eq true
  end

  it 'denies logout with invalid token' do
    post "/jwt/logout?token=#{invalid}"
    expect(response).to have_http_status(302)
    expect(flash[:alert].present?).to eq true
  end
end
