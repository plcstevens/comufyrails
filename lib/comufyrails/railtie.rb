require 'rails'

class Comufyrails::Railtie < Rails::Railtie

  # this allows users to manage settings just like they manage rails settings
  config.comufy = ActiveSupport::OrderedOptions.new

  rake_tasks do
    # load "path/to/my_railtie.tasks"
  end

  initializer "comufyrails.configure_rails_initialization" do |app|
    Comufyrails.configure do |config|
      config.app_name     = app.config.comufy.has_key? :app_name ?
                                                           app.config.comufy[:app_name] : self.app_name
      config.username     = app.config.comufy.has_key? :username ?
                                                           app.config.comufy[:username] : self.username
      config.password     = app.config.comufy.has_key? :password ?
                                                           app.config.comufy[:password] : self.password
      config.access_token = app.config.comufy.has_key? :access_token ?
                                                           app.config.comufy[:access_token] : self.access_token
      config.expiry_date  = app.config.comufy.has_key? :expiry_date ?
                                                           app.config.comufy[:expiry_date] : self.expiry_date
      config.base_api_url = app.config.comufy.has_key? :base_api_url ?
                                                           app.config.comufy[:base_api_url] : self.base_api_url
    end
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

    def self.expiry_token
      ENV.fetch('COMUFY_EXPIRY_TIME', nil)
    end

    def self.base_api_url
      'http://www.sociableapi.com/xcoreweb/client'
    end
end
