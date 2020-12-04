# frozen_string_literal : true

class JwtController < ApplicationController
  respond_to :html, :json

  protect_from_forgery

  before_action :validate_jwt_request, except: %i[index]

  def index
    
  end
  
  def new
    @access_token = bearer_token || body_bearer_token
    session[:login_url] = params[:login_url]
    if user_signed_in?
      user = User.find_by(id: user_id)
      return idp_make_jwt_response generate_token(user) if user.present?
      sign_out
      flash[:alert] = 'User not found!'
    end
    rerender_login_form
  end

  def create
    AuthenticateUser.call(user_params).either(
      ->(user) {
        sign_in(:user, user) if user_params[:remember_me] == "1"
        idp_make_jwt_response generate_token(user)
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

  def login_url
    session[:login_url]
  end
  helper_method :login_url

  def jwt_callback_url
    ValidateToken.call(bearer_token || body_bearer_token).value!.first['callback_url']
  end
  helper_method :jwt_callback_url

  def return_url
    params[:returnUrl]
  end
  helper_method :return_url

  def validate_jwt_request
    result = ValidateToken.call(bearer_token || body_bearer_token)
    return if result.success?
    # Rollbar.info "Validate JWT token error: #{result.failure}"
    Rails.logger.info "Validate JWT token error: #{result.failure}"
    head :forbidden
  end

  def generate_token(user)
    GenerateToken.call(user).value!
  end

  def idp_make_jwt_response(token)
    @access_token = token
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
    ValidateToken
      .call(bearer_token || body_bearer_token)
      .bind { |token| ExtractEmail.call(token) }
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

  def rerender_login_form
    @access_token = params[:token]
    redirect_to "/users/sign_in?token=#{params[:token]}" #render_modal_form 'jwt_idp/idp/new'
  end
end

