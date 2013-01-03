require 'rails'

class Comufyrails::Railtie < Rails::Railtie

  # this allows users to manage settings just like they manage rails settings
  config.comufy_rails = ActiveSupport::OrderedOptions.new # enable namespaced configuration in Rails environment

  initializer "comufyrails.configure" do |app|
    Comufyrails.configure do |config|
      config.app_name     = app.config.comufy_rails[:app_name]      || Comufyrails::Railtie.app_name
      config.username     = app.config.comufy_rails[:username]      || Comufyrails::Railtie.username
      config.password     = app.config.comufy_rails[:password]      || Comufyrails::Railtie.password
      config.access_token = app.config.comufy_rails[:access_token]  || Comufyrails::Railtie.access_token
      config.expiry_time  = app.config.comufy_rails[:expiry_time]   || Comufyrails::Railtie.expiry_time
      config.base_api_url = app.config.comufy_rails[:base_api_url]  || Comufyrails::Railtie.base_api_url
    end
  end

  rake_tasks do
    load "tasks/comufyrails.rake"
  end

  # Add a to_prepare block which is executed once in production
  # and before each request in development
  config.to_prepare do
    # something
  end

  private

    def self.app_name
      ENV.fetch('COMUFY_APP_NAME', ::Rails.application.class.to_s.split("::").first)
    end

    def self.username
      ENV.fetch('COMUFY_USER', nil)
    end

    def self.password
      ENV.fetch('COMUFY_PASSWORD', nil)
    end

    def self.access_token
      ENV.fetch('COMUFY_TOKEN', nil)
    end

    def self.expiry_time
      ENV.fetch('COMUFY_EXPIRY_TIME', nil)
    end

    def self.base_api_url
      'http://www.sociableapi.com/xcoreweb/client'
    end
end
