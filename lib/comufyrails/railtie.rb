require 'rails'

# TODO: Documentation
class Comufyrails::Railtie < Rails::Railtie

  # initialize our logger
  initializer 'Rails logger' do
    Comufyrails.logger = Rails.logger
  end

  # this allows users to manage settings just like they manage rails settings
  config.comufy_rails = ActiveSupport::OrderedOptions.new # enable namespaced configuration in Rails environment

  initializer "comufyrails.configure" do |app|
    Comufyrails.configure do |config|
      config.app_name     = app.config.comufy_rails[:app_name]      || Comufyrails::Railtie.app_name
      config.access_token = app.config.comufy_rails[:access_token]  || Comufyrails::Railtie.access_token
      config.base_api_url = app.config.comufy_rails[:base_api_url]  || Comufyrails::Railtie.base_api_url

      # we just want a date far into the future
      config.expiry_time  = Time.now.to_i + 1000000
    end
  end

  # load our rake tasks into this rails environment.
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

    def self.access_token
      ENV.fetch('COMUFY_TOKEN', nil)
    end

    def self.base_api_url
      ENV.fetch('COMUFY_BASE_API_URL', 'http://www.sociableapi.com/xcoreweb/client')
    end
end
