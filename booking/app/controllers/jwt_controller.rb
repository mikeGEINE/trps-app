class JwtController < ApplicationController
  # skip_before_action :validate_token
  skip_before_action :verify_authenticity_token, :validate_token
  def index
    
  end
  
  def login_request
    redirect_to idp_login_path
  end

  def logout_request
    redirect_to idp_logout_path
  end
  
  def acs
    ValidateToken.call(params[:token]).either(
      ->(token) {
        cookies[:token] = {value: params[:token], expires: ActiveSupport::Duration.build(token.first['exp'])}
        cookies[:was_authorized] = {value: true, expires: ActiveSupport::Duration.build(token.first['exp']), httponly: true}
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
      ->(fail_msg){
        flash[:alert] = t(fail_msg)
      }
    )
    redirect_to jwt_index_path
  end

  private

  def was_authorized?
    cookies[:was_authorized] == 'true'
  end
  helper_method :was_authorized?

  def idp_login_path
    "#{ENV.fetch('SSO_TARGET_URL'){'http://localhost:8085/auth/sso/jwt'}}/login?token=#{login_token}"
  end
  # helper_method :idp_login_path

  def idp_logout_path
    "#{ENV.fetch('SSO_TARGET_URL'){'http://localhost:8085/auth/sso/jwt'}}/logout?token=#{logout_token}"
  end
  # helper_method :idp_logout_path

  def login_token
    GenerateToken.call(ENV.fetch('SSO_CALLBACK_URL')).value!
  end

  def logout_token
    GenerateToken.call(ENV.fetch('SSO_LOGOUT_CALLBACK_URL')).value!
  end
end
