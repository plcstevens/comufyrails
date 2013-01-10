require 'rails'
require 'comufyrails'

class Comufyrails::Railtie < Rails::Railtie

  # this allows users to manage settings just like they manage rails settings
  config.comufy_rails = ActiveSupport::OrderedOptions.new # enable namespaced configuration in Rails environment

  # initialize our logger
  initializer 'Rails logger' do
    Comufyrails.logger = Rails.logger
  end

  initializer "comufyrails.configure" do |app|
    Comufyrails.configure do |c|
      c.app_name     = app.config.comufy_rails[:app_name]     || ENV.fetch('COMUFY_APP_NAME', ::Rails.application.class.to_s.split("::").first)
      c.access_token = app.config.comufy_rails[:access_token] || ENV.fetch('COMUFY_TOKEN',    nil)
      c.url          = app.config.comufy_rails[:url]          || ENV.fetch('COMUFY_URL',      'https://comufy.herokuapp.com/xcoreweb/client')

      # we just want a date far into the future
      c.expiry_time  = Time.now.to_i + 1000000
    end
  end

  # load our rake tasks into this rails environment.
  rake_tasks do
    load "tasks/comufyrails.rake"
  end
end
