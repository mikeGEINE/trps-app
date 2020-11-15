class ApplicationController < ActionController::Base
  before_action :validate_token

  private
  def validate_token
    result = ValidateToken.call(cookies[:token])
    return if result.success?
    # Rollbar.info "Validate JWT token error: #{result.failure}"
    Rails.logger.info "Validate JWT token error: #{result.failure}"
    flash[:alert] = t(result.failure)
    cookies.delete :was_authorized
    redirect_to jwt_index_path
  end
end
