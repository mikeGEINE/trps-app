# Основные моменты реализации ключевых элементов

## Устройство JWT-протокола

1. Аутентикация запроса

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
