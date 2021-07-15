# Основные моменты реализации ключевых элементов

## Устройство JWT-протокола

1. Аутентикация запроса и работающий на это код

  Имеем контроллеры вида:

  ```ruby
  class MyResourcesController < Api::V1::ApplicationController
    include InteractorsDsl

    def index
      interact_with Resources::Index
    end
  # ...
  end
  ```

  ..., наследуемые от:

  ```ruby
  class Api::V1::ApplicationController
    include JsonApiController
    include Authentication::Api

    before_action :authorize_request

    rescue_from Authentication::Api::Unauthorized, with: :render_unauthorized
  end
  ```

  ..., в котором используются:

  ```ruby
  module JsonApiController
    extend ActiveSupport::Concern

    included do
      include ActionController::Cookies

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
    end

    private

    def render_not_found
      render json: {
        errors: [
          {
            title: 'Not found',
            status: 404
          }
        ]
      }, status: :not_found
    end

    def render_error(messages:)
      render json: {
        errors: Array.wrap(messages)
      }, status: :unprocessable_entity
    end

    def render_unauthorized
      render json: {
        errors: [
          {
            title: 'Unauthorized',
            status: 401
          }
        ],
      }, status: :unauthorized
    end
  end
  ```

  и

  ```ruby
  module Authentication::Api
    private

    def authorize_request
      raise Unauthorized unless request_valid?
    end

    def request_valid?
      RequestValidator
        .call(request, cookies)
        .value_or false
    end

    class Unauthorized < StandardError; end
  end
  ```

  Класс RequestValidator — это *интерактор*, определяющий валидность запроса:

  ```ruby
  require 'dry/monads'

  class RequestValidator < BaseInteractor
    include Dry::Monads[:result, :do]

    param :request
    param :cookies

    def call
      validate.or do |err|
        log_request_validation_error(err)
        Failure(err)
      end
    end

    private

    def validate
      token = yield ExtractAccessToken.call(request, cookies: cookies)
      ValidateToken.call(token)
    end

    def log_request_validation_error(err)
      Rails.logger.error "Request invalid: #{err}"
    end
  end
  ```

  Этот интерактор наследуется от базового:

  ```ruby
  class BaseInteractor
    extend Dry::Initializer

    class << self
      # Instantiates and calls the service at once
      def call(*args, &block)
        new(*args).call(&block)
      end

      # Accepts both symbolized and stringified attributes
      def new(*args)
        args << args.pop.symbolize_keys if args.last.is_a?(Hash)
        super(*args)
      end
    end

    private

    def error_message(key, **attrs)
      I18n.t("interactors.#{self.class.name.underscore.tr('/', '.')}.errors.#{key}", attrs)
    end

    class Error < StandardError; end
  end
  ```

  ... и использует интеракторы:

  ```ruby
  require 'dry/monads'

  class ExtractAccessToken < TokenExtractor
    include Dry::Monads[:maybe]

    private

    def extract_from_cookies(cookies)
      Maybe(cookies[:access_token])
    end
  end
  ```

  и

  ```ruby
  class ValidateToken < BaseInteractor
    param :token

    def call
      JwtValidator.call(token).fmap { |_| true }
    end
  end
  ```

  Валидатор устроен так:

  ```ruby
  require 'dry/monads'
  require 'jwt'

  class JwtValidator
    include Dry::Monads[:result, :do]

    def call(token)
      issuer = yield get_issuer(token)
      rsa_public = yield get_public_key(issuer)
      decoded_token = yield validate(token: token, rsa_public: rsa_public)

      Success(decoded_token.first)
    end

    class << self
      delegate :call, to: :new
    end

    private

    # This & others use https://github.com/jwt/ruby-jwt
    def get_issuer(token)
      payload = JWT.decode(token, nil, false).first

      Success(payload['iss'])
    rescue JWT::DecodeError => e
      Failure(InvalidToken.new(e))
    end

    def get_public_key(issuer)
      issuer_key_file = public_key_file(issuer)

      public_key = File.read issuer_key_file
      rsa_public = OpenSSL::PKey::RSA.new(public_key) if public_key

      Success(rsa_public)
    rescue Errno::ENOENT
      Failure(PubKeyNotFound.new)
    rescue OpenSSL::PKey::RSAError => e
      Failure(RSAError.new(e))
    end

    def validate(token:, rsa_public:)
      decoded_token = JWT.decode(token, rsa_public, true, algorithm: 'RS256')

      Success(decoded_token)
    rescue JWT::DecodeError => e
      Failure(InvalidToken.new(e))
    end

    def public_key_file(iss)
      File.join(ENV.fetch('RSA_PUBLIC_DIR') { './' }, "#{iss}.pem")
    end

    class PubKeyNotFound < StandardError; end

    class RSAError < StandardError; end

    class InvalidToken < StandardError; end
  end
  ```

  Экстрактор токена — так:

  ```ruby
  require 'dry/monads'

  class TokenExtractor < BaseInteractor
    include Dry::Monads[:maybe, :result]

    param :request
    option :cookies

    def call
      extract_from_bearer(request)
        .or { extract_from_cookies(cookies) }
        .to_result
        .or Failure(TokenNotFound.new)
    end

    private

    # template
    def extract_from_cookies(_)
      None()
    end

    def extract_from_bearer(request)
      Maybe(request.authorization.presence)
        .bind { |header| Maybe(header.match(/^Bearer (.*)/).to_a[1].presence) }
    end

    class TokenNotFound < Error; end
  end
  ```

2. Некоторые детали сервера IDP

  IDP-сервер — простое редльсовое приложение, которое видит базу юзеров для того, чтобы их логинить/логаутить.
  После логина/логаута IDP должен сообщить результат операции сервису, для которого он эту оп-ю производит.
  Состоит из одного контроллера:

  ```ruby
  class JwtController
    protect_from_forgery

    before_action :validate_jwt_request

    # инициирует логин
    def new
      @access_token = bearer_token || body_bearer_token

      if signed_in?(:user)
        user = User.find_by(id: user_id)

        # отображает "скрытую форму"
        return idp_make_jwt_response generate_token(user) if user.present?

        sign_out
        flash[:alert] = t('.user_not_found')
      end

      # форма логина
      render_login_form 'jwt_idp/idp/new'
    end

    def create
      AuthenticateUser.call(user_params).either(
        ->(user) {
          sign_in(:user, user.id) if ActiveModel::Type::Boolean.new.cast(user_params[:remember_me])

          # "скрытая форма"
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

    def jwt_callback_url
      params[:callbackUrl]
    end
    helper_method :jwt_callback_url

    def return_url
      params[:returnUrl]
    end
    helper_method :return_url

    def validate_jwt_request
      result = ValidateToken.call(bearer_token || body_bearer_token)
      return if result.success?

      Rollbar.info "Validate JWT token error: #{result.failure}"
      Rails.logger.info "Validate JWT token error: #{result.failure}"

      head :forbidden
    end

    def generate_token(user)
      GenerateAccessToken.call(user).value!
    end

    def idp_make_jwt_response(tokens)
      @access_token = tokens.access
      render template: 'jwt_idp/idp/jwt_post', layout: false
    end

    def idp_make_logout_jwt_response(user)
      GenerateToken.call(user).fmap { |token| @access_token = token }
      render template: 'jwt_idp/idp/jwt_post', layout: false
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

    def rerender_login_form
      @access_token = params[:token]
      render_login_form 'jwt_idp/idp/new'
    end
  end
  ```

  Полезные интеракторы для idp jwt-контроллера:

  ```ruby
  class BasicInteractor
    class << self
      delegate :call, to: :new
    end

    class Error < StandardError; end
  end
  ```

  ```ruby
  require 'dry/monads'

  class AuthenticateUser < BasicInteractor
    include Dry::Monads[:maybe, :result, :do]

    def call(params)
      email = yield try_extract(params, :email, '.no_email')
      password = yield try_extract(params, :password, '.no_password')
      try_authenticate(email, password, '.incorrect_email_or_password')
    end

    private

    def try_extract(data, key, err_key)
      Maybe(data[key].presence).to_result err_key
    end

    def try_authenticate(email, password, err_key)
      Maybe(User.find_by(email: email))
        .to_result
        .bind { |user| user.valid_password?(password) ? Success(user) : Failure() }
        .or Failure(err_key)
    end
  end
  ```

  ```ruby
  require 'dry/monads'

  class GenerateToken < BAsicInteractor
    include JwtConfigurable
    include Dry::Monads[:result]

    def call(user)
      rsa_private = OpenSSL::PKey::RSA.new(private_key_file)
      access_payload = generate_access_payload(user)
      access_token = JWT.encode access_payload, rsa_private, 'RS256'

      Success(access_token)
    end

    private

    def generate_access_payload(user)
      jwt_payload(
        user: user,
        exp_from: -> { access_token_ttl.to_i.minutes.since.to_i }
      )
    end

    # rubocop:disable Metrics/MethodLength
    # :reek:BooleanParameter
    def jwt_payload(user:, exp_from:, refresh: false)
      {
        sub: 'idp-logout',
        iss: service_name,
        exp: exp_from.call,
        refresh_token: refresh
      }.tap do |hsh|
        user.present? && hsh.merge!(
          sub: user.id,
          email: user.email,
          role: user.role
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def private_key_file
      File.read File.join(rsa_private_dir, 'private.pem')
    end
  end
  ```

  ```ruby
  module JwtConfigurable
    private

    delegate :service_name,
             :access_token_ttl,
             :refresh_token_ttl,
             :rsa_private_dir,
             :rsa_public_dir,
             to: :jwt_config

    private :service_name,
            :access_token_ttl,
            :refresh_token_ttl,
            :rsa_private_dir,
            :rsa_public_dir

    def jwt_config
      @jwt_config ||= OpenStruct.new Rails.configuration.jwt
    end
  end
  ```

  Пример рельсовой конфиг-и:

  ```ruby
  config.service_name = ENV.fetch('SERVICE_NAME') { 'idp' }

  config.jwt = {
    service_name: config.service_name,
    access_token_ttl: ENV.fetch('JWT_EXPIRE_TIME') { 30 },
    refresh_token_ttl: ENV.fetch('JWT_REFRESH_EXPIRE_TIME') { 1 },
    rsa_private_dir: ENV.fetch('RSA_PRIVATE_DIR') { './' },
    rsa_public_dir: ENV.fetch('RSA_PUBLIC_DIR') { './' }
  }
  ```

  ### Скрытая форма:

  ```irb
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    </head>
    <body onload="document.forms[0].submit();" style="visibility:hidden;">
      <%= form_tag(jwt_callback_url) do %>
        <%= hidden_field_tag("access_token", @access_token) %>
        <%= hidden_field_tag("return_url", return_url) %>
        <%= submit_tag "Submit" %>
      <% end %>
    </body>
  </html>
  ```

  3. [Элементы протокола (см. диаграмму)](jwt-protocol.md)
