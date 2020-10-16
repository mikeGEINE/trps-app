# frozen_string_literal : true

class JwtController < ApplicationController
  respond_to :html, :json

  protect_from_forgery

  # before_action :validate_jwt_request

  def new
    @access_token = bearer_token || body_bearer_token
    if signed_in?(:user)
      user = User.find_by(id: user_id)
      return idp_make_jwt_response generate_tokens(user) if user.present?
      sign_out
      flash[:alert] = 'User not found!'
    end
    redirect_to '/users/sign_in' # render_modal_form 'jwt_idp/idp/new'
  end

  def create
    AuthenticateUser.new.call(user_params).either(
      ->(user) {
        sign_in(:user, user.id) if ActiveModel::Type::Boolean.new.cast(user_params[:remember_me])
        idp_make_jwt_response generate_tokens(user)
      },
      ->(failure_msg_key) {
        flash[:alert] = t(failure_msg_key)
        rerender_login_form
      }
    )
  end

  # приходит токен д/аутентикации запроса, который подписан сервисом-клиентом
  def logout
    user = logout_user
    sign_out
    idp_make_logout_jwt_response(user)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end

  def jwt_callback_url
    root_url # params[:callbackUrl]
  end
  helper_method :jwt_callback_url

  def return_url
    params[:returnUrl]
  end
  helper_method :return_url

  def validate_jwt_request
    result = ValidateToken.new.call(bearer_token || body_bearer_token)
    return if result.success?
    # Rollbar.info "Validate JWT token error: #{result.failure}"
    Rails.logger.info "Validate JWT token error: #{result.failure}"
    head :forbidden
  end

  def generate_tokens(user)
    GenerateTokens.new.call(user).fmap { |tokens|
      tokens
    }.value!
  end

  def idp_make_jwt_response(tokens)
    @access_token = tokens.access
    render template: 'jwt/post', layout: false
  end

  def idp_make_logout_jwt_response(user)
    GenerateToken.call(user).fmap { |token| @access_token = token }
    render template: 'jwt/post', layout: false
  end

  def bearer_token
    match = request.authorization&.match(/^Bearer (.*)/)
    match.present? ? match[1] : nil
  end

  def body_bearer_token
    params[:token]
  end

  def logout_user
    ValidateTokens
      .call(bearer_token || body_bearer_token)
      .bind { |email| AcceptValue.call(email) }
      .either(
        ->(email) { User.find_by(email: email) },
        ->(_) { User.find_by(id: warden.user(:user)) }
      )
  end

  def user_id
    @user_id ||= begin
      scope = warden.user(scope: :user)
      scope.is_a?(Hash) ? scope['id'] : scope
    end
  end

  # def prev_refresh_token
  #   @prev_refresh_token ||= params[:prev_refresh_token]
  # end

  def rerender_login_form
    @access_token = params[:token]
    redirect_to '/users/sign_in' #render_modal_form 'jwt_idp/idp/new'
  end
end

