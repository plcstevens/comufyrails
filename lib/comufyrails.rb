require 'rails'

require "comufyrails/version"
require "comufyrails/connection"
require 'comufyrails/railtie' if defined?(Rails)

module Comufyrails

  STRING_TYPE = "STRING"
  DATE_TYPE   = "DATE"
  GENDER_TYPE = "GENDER"
  INT_TYPE    = "INT"
  FLOAT_TYPE  = "FLOAT"
  LEGAL_TYPES = [STRING_TYPE, DATE_TYPE, GENDER_TYPE, INT_TYPE, FLOAT_TYPE]

  class Config
    attr_accessor :app_name, :access_token, :expiry_time, :base_api_url
  end

  def self.config
    @@config ||= Config.new
  end

  def self.configure
    yield self.config
  end
end
