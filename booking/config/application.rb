require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Booking
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_record.schema_format = :sql

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post options]
      end
    end

    config.service_name = ENV.fetch('SERVICE_NAME') { 'booking' }

    config.jwt = {
      service_name: config.service_name,
      access_token_ttl: ENV.fetch('JWT_EXPIRE_TIME', 30).to_i,
      rsa_private_dir: ENV.fetch('RSA_PRIVATE_DIR') { './' },
      rsa_public_dir: ENV.fetch('RSA_PUBLIC_DIR') { './' }
    }
  end
end
