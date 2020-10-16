# frozen_string_literal: true

module JwtConfigurable
  
  def rsa_private_dir
    Rails.configuration.jwt[:rsa_private_dir]
  end
  
  def rsa_public_dir
    Rails.configuration.jwt[:rsa_public_dir]
  end

  def service_name
    Rails.configuration.jwt[:service_name]
  end

  def access_token_ttl
    Rails.configuration.jwt[:access_token_ttl]
  end
end
