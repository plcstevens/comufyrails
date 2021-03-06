require "em-synchrony"
require "em-synchrony/em-http"
require 'comufyrails'

# This module contains asynchronous methods for contacting the +comufy.url+ specified in +Config+.
# It uses +em-synchrony+ and +EventMachine+ to achieve this, and therefore to be run asynchronously you
# must use a web server that supports these such as +thin+.
#
# Methods to store users or send messages all return their results to logs, as they do not provide any information
# back to the user.
#
# Requests for users and tags can return information and will yield to a block if provided, otherwise they will
# also print to the log. This is often useful for debugging, but in practise you should provide these with a block.
module Comufyrails
  module Connection
    class << self

      # Shortened method name for storing a user, or users in your Application.
      # Please see +store_users+ for details.
      def store(uids, tags) self.store_user(uids, tags) end

      # This API call allows you to register a Facebook user of your application into Comufy’s social CRM.
      # If this user was already registered with Comufy, their information will be updated.
      #
      # * (String) +uid+ - The Facebook ID of the user you'll be adding.
      # * (Hash) +tags+ - The tags you'll setting for this user.
      #   * (String) +tag_name+ - Must correspond to one of the tag names of the application.
      #   * (String) +value+ - Must be the correct value type for that tag.
      #
      # = Example
      #
      #   Comufyrails::Connection.store_user USER_FACEBOOK_ID, { dob: '1978-10-01 19:50:48' }
      def store_user(uids, tags)
        uids = [uids] unless uids.is_a? Array
        tags = [tags] unless tags.is_a? Array
        self.store_users(uids, tags)
      end

      # This API call allows you to register multiple Facebook users of your application into Comufy’s social CRM.
      # If these users were already registered into Comufy, their information will be updated.
      #
      # Please note that you can provide a single String or Integer for uids and one +tag+ if you wish.
      #
      # * (Array) +uids+ - A list of (String/Integer) user ids you wish to add/update.
      # * (Array) +tags+ - A list of hashes for each of the users.
      #   * (Hash) +tag+
      #     * (String) +tag_name+ - Must correspond to one of the tag names of the application.
      #     * (String) +value+    - Must be the correct value type for that tag.
      #
      # = Example
      #
      #   Comufyrails::Connection.store_users(
      #     [ USER_ID, USER_ID_2 ],
      #     [ { 'dob' => '1978-10-01 19:50:48' }, { 'dob' => '1978-10-01 19:50:48'}]
      #   )
      def store_users(uids, tags)
        raise ArgumentError, "uids must be an Array." unless uids.is_a? Array
        raise ArgumentError, "tags must be an Array." unless tags.is_a? Array

        # Ensure the tags are valid
        tags.each(&:symbolize_keys!)
        zipped = uids.zip(tags)

        data = {
            cd:              '88',
            token:           Comufyrails.config.access_token,
            applicationName: Comufyrails.config.app_name,
            accounts:        zipped.map { |uid, tagged | Hash[:account, { fbId: uid.to_s }, :tags, tagged] }
        }
        EM.synchrony do
          http = EventMachine::HttpRequest.new(Comufyrails.config.url).post(
              :body => { request: data.to_json }, :initheader => { 'Content-Type' => 'application/json' })
          if http.response_header.status == 200
            message = JSON.parse(http.response)
            case message["cd"]
              when 388 then
                Comufyrails.logger.debug("Success! Method: store_users, data: #{data}, response: #{message}.")
              when 475 then
                Comufyrails.logger.debug("Invalid parameter provided! Method: store_users, data: #{data}, response: #{message}.")
              when 617 then
                Comufyrails.logger.debug("Some of the tags passed are not registered! Method: store_users, data: #{data}, response: #{message}.")
              when 632 then
                Comufyrails.logger.debug("_ERROR_FACEBOOK_PAGE_NOT_FOUND! Method: store_users, data: #{data}, response: #{message}.")
              else
                Comufyrails.logger.debug("Unknown response from server! Method: store_users, data: #{data}, response: #{message}.")
            end
          else
            Comufyrails.logger.warn("Bad response from server: #{http.response_header}.")
          end
        end
      end

      # Shorthand method for sending messages to the selected uids. See +send_facebook_message+ for more information.
      def message(desc, content, uids, opts = {}) self.send_facebook_message(desc, content, uids, opts) end

      # Sends a message with the description and content to the facebook id or id's specified, allowing multiple
      # options to be set concerning the privacy, and content of the message.
      #
      # * (String) +description+ - Description of the message. Useful to aggregate data in the Comufy dashboard.
      # * (String) +content+ - The text message content.
      # * (Array) +uids+ - The Facebook IDs of the users to send the message to.
      # * (Hash) +opts+ - Optional settings you can pass.
      #   * (Integer) +delivery_time+ - The scheduled time of delivery defaults to now. (Unix millisecond timestamps)
      #   * (Boolean) +shorten_urls+ - UNTRACKED if false, otherwise defaults to Comufy TRACKED
      #   * (String) +filter+ - filtering condition in CFL.
      #   * (Hash) +message_options+ - options to set for the message especially.
      #     * (String) +name+ - facebook message name.
      #     * (String) +link+ - Facebook message link.
      #     * (String) +caption+ - facebook message caption.
      #     * (String) +description+ - description of the message.
      #     * (String) +picture+ - URL of the image that should appear on the image section of the message.
      #     * (Boolean) +privacy+ -  whether the message should be sent private or not.
      #
      # = Example
      #    Comufyrails::Connection.send_facebook_message(
      #      DESCRIPTION, CONTENT_GOES_HERE, UIDS,
      #      message_options: {
      #        private: true, link: 'www.example.com', name: 'test', description: 'description'
      #      }
      #    )
      def send_facebook_message(description, content, uids, opts = {})
        raise ArgumentError, "Description must be a String."           unless description.is_a? String
        raise ArgumentError, "Content must be a String."               unless content.is_a? String
        raise ArgumentError, "Uids must be an Array."                  unless uids.is_a? Array
        raise ArgumentError, "Opts must be a Hash if you include it."  unless opts.is_a? Hash

        opts.symbolize_keys!

        facebook_ids  = "FACEBOOK.ID=\"#{uids.join('\" OR FACEBOOK.ID=\"')}\""
        filter        = opts[:filter] || ""
        delivery_time = opts[:delivery_time]
        shorten_urls  = opts.has_key?(:shorten_urls) ? opts[:shorten_urls] : true
        options       = opts[:message_options]

        data = {
            cd:              83,
            token:           Comufyrails.config.access_token,
            applicationName: Comufyrails.config.app_name,
            description:     description,
            content:         content,
            filter:          "#{facebook_ids} #{filter}"
        }
        data[:deliveryTime]           = delivery_time if delivery_time
        data[:trackingMode]           = "UNTRACKED" unless shorten_urls
        data[:facebookTargetingMode]  = "NOTIFICATION"

        if options
          data[:fbMessagePrivacyMode] = options[:private] ? "PRIVATE" : "PUBLIC" if options.has_key?(:private)
          data[:fbMessageCaption]     = options[:caption]                        if options.has_key?(:caption)
          data[:fbMessageLink]        = options[:link]                           if options.has_key?(:link)
          data[:fbMessageName]        = options[:name]                           if options.has_key?(:name)
          data[:fbMessageDescription] = options[:description]                    if options.has_key?(:description)
          data[:fbMessagePictureUrl]  = options[:picture]                        if options.has_key?(:picture)
        end

        EM.synchrony do
          http = EventMachine::HttpRequest.new(Comufyrails.config.url).post(
              :body => { request: data.to_json }, :initheader => { 'Content-Type' => 'application/json' })
          if http.response_header.status == 200
            message = JSON.parse(http.response)
            case message["cd"]
              when 383 then
                Comufyrails.logger.debug("Success! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 416 then
                Comufyrails.logger.debug("_ERROR_MSG_SEND_FAILED! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 475 then
                Comufyrails.logger.debug("Invalid parameters provided! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 551 then
                Comufyrails.logger.debug("_ERROR_TAG_VALUE_NOT_FOUND! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 603 then
                Comufyrails.logger.debug("_ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 607 then
                Comufyrails.logger.debug("_ERROR_UNAUTHORISED_ACTION! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 617 then
                Comufyrails.logger.debug("_ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 648 then
                Comufyrails.logger.debug("_ERROR_FACEBOOK_APPLICATION_USER_NOT_FOUND! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 673 then
                Comufyrails.logger.debug("Invalid time exception! Method: send_facebook_message, data: #{data}, response: #{message}.")
              when 679 then
                Comufyrails.logger.debug("_ERROR_MALFORMED_TARGETING_EXPRESSION! Method: send_facebook_message, data: #{data}, response: #{message}.")
              else
                Comufyrails.logger.debug("Unknown response from server! Method: send_facebook_message, data: #{data}, response: #{message}.")
            end
          else
            Comufyrails.logger.warn("Bad response from server: #{http.response_header}.")
          end
        end
      end

      # Provides a list of all tags for this application. If you provide a block it will yield the response,
      # otherwise it will be sent the log.
      def tags
        data = {
            cd:               101,
            token:            Comufyrails.config.access_token,
            applicationName:  Comufyrails.config.app_name
        }

        EM.synchrony do
          http = EventMachine::HttpRequest.new(Comufyrails.config.url).post(
              :body => { request: data.to_json }, :initheader => { 'Content-Type' => 'application/json' })
          if http.response_header.status == 200
            message = JSON.parse(http.response)
            if block_given?
              # TODO: Cut into the response to make it easier for users to use this function.
              yield message
            else
              case message["cd"]
                when 219 then
                  Comufyrails.logger.debug("Success! method: tags, data: #{data}, response: #{message}.")
                else
                  Comufyrails.logger.debug("Unknown response from server! Method: tags, data: #{data}, response: #{message}.")
              end
            end
          else
            Comufyrails.logger.warn("Bad response from server: #{http.response_header}.")
          end
        end
      end

      def user(facebook_id)
        filter = "FACEBOOK.ID=\"#{facebook_id}\""
        self.users(filter)  do |users, total, to, from|
          user    = users.delete_at(0)
          account = user ? user.delete("account")   : { }
          tags    = user ? user.delete("tagValues") : { }
          other   = { users: users, total: total, to: to, from: from }.with_indifferent_access
          yield account, tags, other
        end
      end

      # Lists all current users data, with any additional filters you want.
      # If you provide a block it will yield the response, otherwise it will be sent the log.
      # TODO: Replace USER.USER_STATE with something we know will get all users.
      def users filter = ""
        filter = 'USER.USER_STATE="Unknown"' if filter.empty?
        data = {
            cd:               82,
            token:            Comufyrails.config.access_token,
            applicationName:  Comufyrails.config.app_name,
            since:            1314835200000,
            fetchMode:        "ALL",
            filter:           filter
        }

        EM.synchrony do
          http = EventMachine::HttpRequest.new(Comufyrails.config.url).post(
              :body => { request: data.to_json }, :initheader => { 'Content-Type' => 'application/json' })
          if http.response_header.status == 200
            message = JSON.parse(http.response).with_indifferent_access
            blocks  = message.clone.delete("timeBlocks")
            total = blocks.first ? blocks.first.delete("total")               : 0
            to    = blocks.first ? blocks.first.delete("to")                  : 0
            from  = blocks.first ? blocks.first.delete("from")                : 0
            users = blocks.first && total > 0 ? blocks.first.delete("data")   : [ ]

            if block_given?
              yield users, total, to, from
            else
              case message["cd"]
                when 382 then
                  Comufyrails.logger.debug("Success! Method: users, data: #{data}, response: #{message}.")
                  Comufyrails.logger.info("#{total} user(s) were found matching your filter.\n #{users}")
                when 692 then
                  Comufyrails.logger.debug("Invalid filter/filter not found! Method: users, data: #{data}, response: #{message}.")
                  Comufyrails.logger.info("Invalid filter/filter not found. #{users}")
                else
                  Comufyrails.logger.debug("Unknown response from server! Method: users, data: #{data}, response: #{message}.")
                  Comufyrails.logger.info("Unknown response from server. #{users}")
              end
            end
          else
            Comufyrails.logger.warn("Bad response from server: #{http.response_header}.")
          end
        end
      end

    end
  end

end
