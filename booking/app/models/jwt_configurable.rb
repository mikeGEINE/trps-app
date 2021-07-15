# frozen_string_literal: true

module JwtConfigurable
  delegate :service_name,
           :access_token_ttl,
           :rsa_private_dir,
           :rsa_public_dir,
           to: :jwt_config

  private :service_name,
          :access_token_ttl,
          :rsa_private_dir,
          :rsa_public_dir

  def jwt_config
    @jwt_config ||= OpenStruct.new Rails.configuration.jwt
  end
end
