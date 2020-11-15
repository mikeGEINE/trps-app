# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

LOGIN = 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjoyNjA1MzczODU4LCJjYWxsYmFja191cmwiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvand0L2FjcyJ9.ZjM_pr465BJXLloDHRpCWlcMo87bvC0Mo1-VpMyJKppin9l105UpHas6kZOBwMYpCvCIq0NKk78wFFBl1fLh18wEA23ZvEQMKKEWmqcc5mSn8JZ9PqCAMPOV8TcZL7OibzHW87jd6XL6TgSTTiq9L7WKmn50uD4dUat7YHWGzUKUn1plP97HlSBPaPZdSxpL4IfQKeAabqelooZ4vYA91iD00U8Ch4Kn5cl85iAux2Hz7ctVAfB06_CcbPkXBviuioUNCg6Xw1RUX3zmX1pJdlefRplpjp6nX8U0LyOvJF8MMLp-d8wHqULZea5v8IMHuooPih00fa6DlrnOHnIsUw'
LOGOUT = 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjoyNjA1Mzc0MDA4LCJjYWxsYmFja191cmwiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvand0L2xvZ291dCJ9.NTJqfFFZA8N-ur9EY1qiQPk4dopUBgU8M5l1Bw-Eh2rhYlkYj8mK4IHVxome4Ohgk3W-9owRUq9SjJSdArEzZCwINi9JjJWPrFw_JQxEiPjTZdPmpvyGYTv57bKgMpRpw8JaSbwSEYFc3BYaTDd3Kt6ThKx_t-7vpqZQukbPSx_Pc7gcTT-9EfHnSNRM12tH0_laWkvrOFq1cxwDKrnCsVBCwBk3PmQhu1gEgK2mEdrtcToHfaKDBEOd3pcHz204iB3Ox0miJHYYAYKWKmj1r5fMMbgWE65C1CFQCtCoI-piMbczprtptIeeLSNlNUrIGhrEF6AHugFNO56ikRAoHw'

RSpec.describe 'Jwt', type: :request do
  it 'shows index in any case' do
    get jwt_index_path
    expect(response).to have_http_status(200)
  end

  it 'redirects to login form with a token' do
  get "/auth/sso/jwt/login?token=#{LOGIN}"
  follow_redirect!
  expect(response).to have_http_status(200)
  end

  it 'does not load #new without token' do
    get '/auth/sso/jwt/login'
    expect(response).to have_http_status(403)
  end

  it 'logouts user with token' do
    get "/auth/sso/jwt/logout?token=#{LOGOUT}"
    expect(response).to have_http_status(200)
  end

  it 'does not load #logout without token' do
    get '/auth/sso/jwt/logout'
    expect(response).to have_http_status(403)
  end
end
