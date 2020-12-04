# frozen_string_literal: true

require 'dry/monads'
require 'jwt'

class GenerateToken < BasicInteractor
  include JwtConfigurable
  
  param :callback_url, optional: true

  def call
    rsa_private = yield get_private_key
    access_token = JWT.encode generate_payload, rsa_private, 'RS256'
    Success(access_token)
  end
  
  private
  
  def generate_payload
    {
      iss: service_name,
      exp: access_token_ttl.minutes.since.to_i,
      callback_url: callback_url
    }
  end

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
