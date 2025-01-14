require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "brest"
require 'byebug'
require 'store_model'
require 'enum_ext'
require 'warden'
require 'swagger/blocks'
require 'rails_sql_prettifier'

module BrestTest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 6.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_paths += Dir[Rails.root.join('lib', '{ext}'),
                                 Rails.root.join( 'app_doc', '{,*/}')]

    config.eager_load_paths += Dir[Rails.root.join('lib', '{ext}'),
                                   Rails.root.join( 'app_doc', '{,*/}')]


    config.eager_load = true
    config.rake_eager_load = true
    config.default_url_options = { host: '0.0.0.0', port: 3000, protocol: 'http' }

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end

require 'ext/exception_ext'
