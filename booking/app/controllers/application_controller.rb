class ApplicationController < ActionController::Base
  before_action :validate_token

  private
  def validate_token
    ValidateTokens.new.call(cookies[:token])
    return if result.success?
    # Rollbar.info "Validate JWT token error: #{result.failure}"
    Rails.logger.info "Validate JWT token error: #{result.failure}"
    redirect_to jwt_new_path
  end
end
