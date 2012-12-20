require 'rails'

class Comufyrails::Railtie < Rails::Railtie

  # this allows users to manage settings just like they manage rails settings
  config.comufy = ActiveSupport::OrderedOptions.new

  rake_tasks do
    # load "path/to/my_railtie.tasks"
  end

  initializer "comufyrails.configure_settings" do |app|
    #unless defined?(COMUFY)
    #  silence_warnings { Object.const_set "COMUFY", app.config.comufy }
    #end
    Comufyrails.configure do |config|
      config.app_name     = app.config.comufy.delete(:app_name)     || self.app_name
      config.username     = app.config.comufy.delete(:username)     || self.username
      config.password     = app.config.comufy.delete(:password)     || self.password
      config.access_token = app.config.comufy.delete(:access_token) || self.access_token
      config.expiry_date  = app.config.comufy.delete(:expiry_date)  || self.expiry_date
      config.base_api_url = app.config.comufy.delete(:base_api_url) || self.base_api_url
    end
  end

  # Add a to_prepare block which is executed once in production
  # and before each request in development
  config.to_prepare do
    # something
  end

  private

    def self.app_name
      ::Rails.application.class.to_s.split("::").first
    end

    def self.username
      # TODO: look in the environment for comufy settings before returning nil

    end

    def self.password
      # TODO: look in the environment for comufy settings before returning nil

    end

    def self.access_token
      # TODO: look in the environment for comufy settings before returning nil

    end

    def self.expiry_token
      # TODO: look in the environment for comufy settings before returning nil

    end

    def self.base_api_url
      'http://www.sociableapi.com/xcoreweb/client'
    end
end
