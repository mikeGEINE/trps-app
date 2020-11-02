class JwtController < ApplicationController
  # skip_before_action :validate_token
  skip_before_action :verify_authenticity_token
  def new
    redirect_to idp_login_path(GenerateToken.new.call.value!)
  end
  
  def acs
    ValidateToken.call params[:token]
    @result = ValidateToken.call params[:token]
  end

  def logout
    ValidateToken.call params[:token]
    @result = ValidateToken.call params[:token]
  end

  private

  def idp_login_path(token)
    "#{ENV.fetch('SSO_TARGET_URL'){'http://localhost:8085/auth/sso/jwt'}}/login?token=#{token}"
  end

  def idp_logout_path(token)
    "#{ENV.fetch('SSO_TARGET_URL'){'http://localhost:8085/auth/sso/jwt'}}/logout?token=#{token}"
  end
end
