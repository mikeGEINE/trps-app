# frozen_string_literal: true

class JwtController < ApplicationController
  # skip_before_action :validate_token
  skip_before_action :verify_authenticity_token, :validate_token
  def index; end

  def login_request
    redirect_to idp_login_path
  end

  def logout_request
    redirect_to idp_logout_path
  end

  def acs
    ValidateToken.call(params[:token]).either(
      ->(token) {
        cookies[:token] = { value: params[:token], expires: expiry_time(token) }
        cookies[:was_authorized] = { value: true, expires: expiry_time(token), httponly: true }
      },
      ->(fail_msg) {
        flash[:alert] = t(fail_msg)
      }
    )
    redirect_to jwt_index_path
  end

  def logout
    ValidateToken.call(params[:token]).either(
      ->(_) {
        cookies.delete :token
        cookies.delete :was_authorized
      },
      ->(fail_msg) {
        flash[:alert] = t(fail_msg)
      }
    )
    redirect_to jwt_index_path
  end

  private

  def expiry_time(token)
    Time.zone.at(token.first['exp']) + 1.month
  end

  def idp_login_path
    "#{target_url}/login?token=#{login_token}&login_url=#{host_name}/jwt/login_request"
  end

  def idp_logout_path
    "#{target_url}/logout?token=#{logout_token}&login_url=#{host_name}/jwt/login_request"
  end

  def login_token
    GenerateToken.call(ENV.fetch('SSO_CALLBACK_URL')).value!
  end

  def logout_token
    GenerateToken.call(ENV.fetch('SSO_LOGOUT_CALLBACK_URL')).value!
  end

  def target_url
    ENV.fetch('SSO_TARGET_URL', 'http://localhost:8085/auth/sso/jwt')
  end

  def host_name
    ENV.fetch('HOST_NAME', 'http://localhost:8080')
  end
end
