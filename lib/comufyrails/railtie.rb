require 'comufyrails'
require 'rails'

module Comufyrails
  class Railtie < Rails::Railtie

    config.comufy = ActiveSupport::OrderedOptions.new

    rake_tasks do
      # load "path/to/my_railtie.tasks"
    end

    initializer "comufyrails.configure_settings" do |app|
      unless defined?(COMUFY)
        silence_warnings { Object.const_set "COMUFY", app.config.comufy }
      end
    end

    # Add a to_prepare block which is executed once in production
    # and before each request in development
    config.to_prepare do
      # something
    end
  end
end
