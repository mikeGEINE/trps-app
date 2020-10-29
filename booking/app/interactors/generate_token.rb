# frozen_string_literal: true

require 'dry/monads'
require 'jwt'

class GenerateToken < BasicInteractor
  include JwtConfigurable
  
  def call
    rsa_private = OpenSSL::PKey::RSA.new(private_key_file)
    access_payload = generate_payload
    access_token = JWT.encode access_payload, rsa_private, 'RS256'
    Success(access_token)
  end
  
  private
  
  def generate_payload
    {
      iss: service_name,
      exp_from: access_token_ttl.to_i.minutes.since.to_i,
      callback_url: ENV.fetch('SSO_CALLBACK_URL') {'http://localhost:3000/jwt/acs'}
    }
  end
  
  def private_key_file
    File.read File.join(rsa_private_dir, 'private.pem')
  end
end
