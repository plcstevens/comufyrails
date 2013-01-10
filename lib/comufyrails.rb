require 'rails'

require "comufyrails/core_ext"
require "comufyrails/version"
require "comufyrails/constants"
require "comufyrails/connection"
require 'comufyrails/railtie' if defined?(Rails)

module Comufyrails

  # Contains the list of constant variables that will be used throughout this gem.
  class Config
    # Application name on Comufy, and on Facebook.
    attr_accessor :app_name
    # Access token to access your Applications on Comufy.
    attr_accessor :access_token
    # Expiry time of the AccessToken.
    attr_accessor :expiry_time
    # The URL of the Comufy service to connect to.
    attr_accessor :url
  end

  class << self
    # Comufyrails logger (usually uses the Rails.logger)
    attr_accessor :logger

    # define as a Config object unless defined
    def config
      @@config ||= Config.new
    end

    # yield the Comufyrails config class variable
    def configure
      yield self.config
    end
  end
end
