# frozen_string_literal: true

require 'dry/monads'
require 'jwt'

class ValidateToken < BasicInteractor
  include JwtConfigurable

  param :token

  def call
    issuer = yield get_issuer
    public_key = yield get_public_key(issuer)
    decoded_token = yield validate(token: token, rsa_public: public_key)

    Success(decoded_token)
  end

  private

  def get_issuer
    payload = JWT.decode(token, nil, false).first
    Maybe(payload['iss'])
    .to_result
    .or Failure(:no_iss)
  rescue JWT::DecodeError => e
    Failure(:invalid_token)     # InvalidToken.new(e)
  end

  def get_public_key(issuer)
    issuer_key_file = public_key_file(issuer)

    public_key = File.read issuer_key_file
    rsa_public = OpenSSL::PKey::RSA.new(public_key) if public_key

    Success(rsa_public)
  rescue Errno::ENOENT
    Failure(:public_key_not_found)    # PubKeyNotFound.new
  rescue OpenSSL::PKey::RSAError => e
    Failure(:RSA_error)   # RSAError.new(e)
  end

  def validate(token:, rsa_public:)
    decoded_token = JWT.decode(token, rsa_public, true, algorithm: 'RS256')

    Success(decoded_token)
  rescue JWT::DecodeError => e
    Failure(:invalid_token)
  end

  def public_key_file(iss)
    File.join(rsa_public_dir, "#{iss}.pem")
  end

  # class PubKeyNotFound < StandardError; end

  # class RSAError < StandardError; end

  # class InvalidToken < StandardError; end
end
