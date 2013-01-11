require 'json'
require 'net/http'
require 'net/https'
require 'uri'

namespace :comufy do

  desc "Register a tag with your application."
  task :tag , [:name, :type] => :environment do |t, args|
    raise ArgumentError, "Must specify a name for the tag." unless args.name
    args.with_defaults(type: 'STRING')

    if Comufyrails.config.app_name.blank?
      p "
Cannot find the application name, is it currently set to nil or an empty string? Please check
config.comufy_rails.app_name in your environment initializer or the environment variable
COMUFY_APP_NAME are valid strings. And remember you need to register your application with Comufy first with
the comufy:app rake command."
    elsif Comufyrails.config.url.blank?
      p "
Cannot find the base api url, is it currently set to nil or an empty string?\n
Please check config.comufy_rails.url in your environment initializer or the environment variable
COMUFY_URL are valid strings."
    elsif Comufyrails.config.access_token.blank?
      p "
Cannot find the access token, is it currently set to nil or an empty string?\n
Please check config.comufy_rails.access_token in your environment initializer or the environment variable
COMUFY_TOKEN are valid strings."
    elsif not Comufyrails::LEGAL_TYPES.include?(args.type)
      p "
The type must be #{Comufyrails::LEGAL_TYPES.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')}"
    else
      data = {
          cd:              86,
          applicationName: Comufyrails.config.app_name,
          token:           Comufyrails.config.access_token,
          tags:            [{
                                name: args.name,
                                type: args.type.to_sym
                            }]
      }

      uri = URI.parse(Comufyrails.config.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, initheader = { 'Content-Type' => 'application/json' })
      request.set_form_data({ request: data.to_json })
      response = http.request(request)

      if response.message == 'OK'
        message = JSON.parse(response.read_body)
        case message["cd"]
          when 386 then
            p "386 - Success! - data = #{data} - message = #{message}."
          when 475 then
            p "475 - Invalid parameters provided - data = #{data} - message = #{message}."
          when 603 then
            p "603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND - data = #{data} - message = #{message}."
          when 607 then
            p "607 - _ERROR_UNAUTHORISED_ACTION - data = #{data} - message = #{message}."
          when 618 then
            p "618 - _ERROR_DOMAIN_APPLICATION_TAG_ALREADY_REGISTERED - data = #{data} - message = #{message}."
          else
            p  "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
        end
      else
        p "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve this."
      end
    end
  end

  desc "Unregister an existing tag from your application."
  task :detag , [:name] => :environment do |t, args|
    raise ArgumentError, "Must specify a name for the tag." unless args.name

    if Comufyrails.config.app_name.blank?
      puts "
Cannot find the application name, is it currently set to nil or an empty string? Please check
config.comufy_rails.app_name in your environment initializer or the environment variable
COMUFY_APP_NAME are valid strings. And remember you need to register your application with Comufy first with
the comufy:app rake command."
    elsif Comufyrails.config.url.blank?
      p "
Cannot find the base api url, is it currently set to nil or an empty string?
Please check config.comufy_rails.url in your environment initializer or the environment variable
COMUFY_URL are valid strings."
    elsif Comufyrails.config.access_token.blank?
      p "
Cannot find the access token, is it currently set to nil or an empty string?
Please check config.comufy_rails.access_token in your environment initializer or the environment variable
COMUFY_TOKEN are valid strings."
    else
      data = {
          cd:              85,
          applicationName: Comufyrails.config.app_name,
          token:           Comufyrails.config.access_token,
          tag:             args.name
      }

      uri = URI.parse(Comufyrails.config.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, initheader = { 'Content-Type' => 'application/json' })
      request.set_form_data({ request: data.to_json })
      response = http.request(request)

      if response.message == 'OK'
        message = JSON.parse(response.read_body)
        case message['cd']
          when 385 then
            p "385 - Success! - data = #{data} - message = #{message}."
          when 475 then
            p "475 - Invalid parameters provided - data = #{data} - message = #{message}."
          when 603 then
            p "603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND - data = #{data} - message = #{message}."
          when 607 then
            p "607 - _ERROR_UNAUTHORISED_ACTION - data = #{data} - message = #{message}."
          when 617 then
            p "617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND - data = #{data} - message = #{message}."
          else
            p "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
        end
      else
        p "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve this."
      end
    end
  end

  desc "Register an application with Comufy"
  task :app , [:name, :id, :secret, :description] => :environment do |t, args|
    raise ArgumentError, "Must specify a name for the application."                     unless args.name
    raise ArgumentError, "Must specify a facebook application id for the application."  unless args.id
    raise ArgumentError, "Must specify a facebook secret for the application."          unless args.secret
    raise ArgumentError, "Must specify a description for the application."              unless args.description

    if Comufyrails.config.url.blank?
      p "
Cannot find the base api url, is it currently set to nil or an empty string?\n
Please check config.comufy_rails.url in your environment initializer or the environment variable
COMUFY_URL are valid strings."
    elsif Comufyrails.config.access_token.blank?
      p "
Cannot find the access token, is it currently set to nil or an empty string?\n
Please check config.comufy_rails.access_token in your environment initializer or the environment variable
COMUFY_TOKEN are valid strings."
    else
      data = {
        cd:                 106,
        token:              Comufyrails.config.access_token,
        name:               args.name,
        description:        args.description,
        applicationId:      args.id,
        applicationSecret:  args.secret
      }

      uri = URI.parse(Comufyrails.config.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, initheader = { 'Content-Type' => 'application/json' })
      request.set_form_data({ request: data.to_json })
      response = http.request(request)

      if response.message == 'OK'
        message = JSON.parse(response.read_body)
        case message['cd']
          when 205 then
            p "205 - Success! - data = #{data} - message = #{message}."
          when 602 then
            p "602 - _ERROR_DOMAIN_APPLICATION_NAME_ALREADY_REGISTERED - data = #{data} - message = #{message}."
          when 619 then
            p "619 - _ERROR_DOMAIN_APPLICATION_ALREADY_REGISTERED_UNDER_DIFFERENT_NAME  - data = #{data} - message = #{message}."
          when 645 then
            p "645 - _ERROR_FACEBOOK_AUTHORISATION_FAILURE - data = #{data} - message = #{message}."
          else
            p "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
        end
      else
        p "Authentication failed when sending #{data}. Please get in touch with Comufy if you cannot resolve this."
      end
    end
  end

end
