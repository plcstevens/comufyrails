require 'rails'

require "comufyrails/version"
require 'comufyrails/railtie' if defined?(Rails)

module Comufyrails

  class Config
    attr_accessor :app_name, :username, :password, :access_token, :expiry_time, :base_api_url
  end

  def self.config
    @@config ||= Config.new
  end

end
