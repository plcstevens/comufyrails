require 'json'
require 'net/http'
require 'net/https'

namespace :comufy do

  desc "Register a tag with your application."
  task :register_tag, [:name, :type] => :environment do |t, args|
    raise ArgumentError, "Must specify a name for the tag." unless args.name
    raise ArgumentError, "Must specify a type for the tag." unless args.type

    if Comufyrails.config.app_name.blank?
      p "
        Cannot find the application name, is it currently set to nil or an empty string?\n
        Please check config.comufy_rails.app_name in your environment initializer or the environment variable
        COMUFY_APP_NAME are valid strings.
        "
    elsif Comufyrails.config.base_api_url.blank?
      p "
        Cannot find the base api url, is it currently set to nil or an empty string?\n
        Please check config.comufy_rails.base_api_url in your environment initializer or the environment variable
        COMUFY_BASE_API_URL are valid strings.
        "
    elsif Comufyrails.config.access_token.blank?
      p "
        Cannot find the access token, is it currently set to nil or an empty string?\n
        Please check config.comufy_rails.access_token in your environment initializer or the environment variable
        COMUFY_TOKEN are valid strings.
        "
    elsif not Comufyrails::LEGAL_TYPES.include?(args.type)
      p "The type must be #{Comufyrails::LEGAL_TYPES.to_sentence(
          two_words_connector: ' or ', last_word_connector: ', or ')}"
    else
      data = {
          applicationName: Comufyrails.config.app_name,
          token:           Comufyrails.config.access_token,
          cd:              86,
          tags:            [{
                                name: args.name,
                                type: args.type.to_sym
                            }]
      }
      response = call_api(Comufyrails.config.base_api_url, data)

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
  task :unregister_tag, [:name] => :environment do |t, args|
    raise ArgumentError, "Must specify a name for the tag." unless args.name

    if Comufyrails.config.app_name.blank?
      p "
        Cannot find the application name, is it currently set to nil or an empty string?\n
        Please check config.comufy_rails.app_name in your environment initializer or the environment variable
        COMUFY_APP_NAME are valid strings.
        "
    elsif Comufyrails.config.base_api_url.blank?
      p "
        Cannot find the base api url, is it currently set to nil or an empty string?\n
        Please check config.comufy_rails.base_api_url in your environment initializer or the environment variable
        COMUFY_BASE_API_URL are valid strings.
        "
    elsif Comufyrails.config.access_token.blank?
      p "
        Cannot find the access token, is it currently set to nil or an empty string?\n
        Please check config.comufy_rails.access_token in your environment initializer or the environment variable
        COMUFY_TOKEN are valid strings.
        "
    else
      data = {
          applicationName: Comufyrails.config.app_name,
          token:           Comufyrails.config.access_token,
          cd:              85,
          tag:             args.name
      }
      response = call_api(Comufyrails.config.base_api_url, data)

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
      end
    end
  end

  private

  # posts the form to the given url as json and blocks till a response is given.
  def call_api(url, data)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, initheader = { 'Content-Type' => 'application/json' })
    request.set_form_data({ request: data.to_json })
    http.request(request)
  end

end
