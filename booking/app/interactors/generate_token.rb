# frozen_string_literal: true

require 'dry/monads'
require 'jwt'

class GenerateToken < BasicInteractor
  include JwtConfigurable
  
  def call(callback_url)
    rsa_private = OpenSSL::PKey::RSA.new(private_key_file)
    access_payload = generate_payload(callback_url)
    access_token = JWT.encode access_payload, rsa_private, 'RS256'
    Success(access_token)
  end
  
  private
  
  def generate_payload(callback_url)
    {
      iss: service_name,
      exp_from: access_token_ttl.minutes.since.to_i,
      callback_url: callback_url
    }
  end
  
  def private_key_file
    File.read File.join(rsa_private_dir, 'private.pem')
  end
end
