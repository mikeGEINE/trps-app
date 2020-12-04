# frozen_string_literal: true

require 'dry/monads'
require 'jwt'

class GenerateToken < BasicInteractor
  include JwtConfigurable
  
  param :user

  def call
    rsa_private = yield get_private_key
    access_token = JWT.encode access_payload, rsa_private, 'RS256'
    Success(access_token)
  end
  
  private
  
  def access_payload
    jwt_payload(
      user: user,
      exp_from: -> { access_token_ttl.to_i.minutes.since.to_i }
    )
  end
  
  
  # rubocop:disable Metrics/MethodLength
  # :reek:BooleanParameter
  def jwt_payload(user:, exp_from:)
    {
      iss: service_name,
      exp: exp_from.call,
    }.tap do |hsh|
      user.present? && hsh.merge!(
        sub: user.id,
        email: user.email,
        # role: user.role
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
  
  def get_private_key
    private_key = File.read File.join(rsa_private_dir, 'private.pem')
    rsa_private = OpenSSL::PKey::RSA.new(private_key) if private_key

    Success(rsa_private)
  rescue Errno::ENOENT
    Failure(:private_key_not_found)    # PubKeyNotFound.new
  rescue OpenSSL::PKey::RSAError => e
    Failure(:RSA_error)   # RSAError.new(e)
  end
end
