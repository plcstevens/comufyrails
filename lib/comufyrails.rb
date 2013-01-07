require 'rails'

require "comufyrails/version"
require "comufyrails/connection"
require 'comufyrails/railtie' if defined?(Rails)

# TODO: Documentation
module Comufyrails

  # String data accepted (this is the usual type to use)
  STRING_TYPE = "STRING"
  # Date data (1988-10-01 19:50:48 YYYY-MM-DD HH:mm:SS)
  DATE_TYPE   = "DATE"
  # Gender data (TODO: format?)
  GENDER_TYPE = "GENDER"
  # Integer data accepted (32-bit)
  INT_TYPE    = "INT"
  # Float data accepted (32-bit float)
  FLOAT_TYPE  = "FLOAT"
  # Data types must be one of these formats
  LEGAL_TYPES = [STRING_TYPE, DATE_TYPE, GENDER_TYPE, INT_TYPE, FLOAT_TYPE]

  # Contains the list of constant variables that will be used throughout this gem.
  class Config
    # Application name on Comufy, and on Facebook.
    attr_accessor :app_name
    # Access token to access your Applications on Comufy.
    attr_accessor :access_token
    # Expiry time of the AccessToken.
    attr_accessor :expiry_time
    # The URL of the Comufy service to connect to.
    attr_accessor :base_api_url
  end

  class << self
    def logger
      @@logger
    end

    def logger=(param)
      @@logger ||= param
    end

    # define as a Config object unless defined
    def config
      @@config ||= Config.new
    end

    # yield the Comufyrails config class variable
    def configure
      yield self.config
    end

    def to_comufy_time param
      case param
        when Time
          # nothing need be altered
        when Date
          # nothing need be altered
        when DateTime
          # nothing need be altered
        when String
          # attempt to parse the String
          param = DateTime.parse(param)
        else
          # most likely this will cause an exception, but that is up to the user to handle
      end
      param.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
