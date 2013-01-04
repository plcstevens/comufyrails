require "em-synchrony"
require "em-synchrony/em-http"

module Comufyrails::Connection


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
  def self.store_user(uid, tags)
    raise ArgumentError, "uid cannot be nil" unless uid
    self.store_users([uid], [tags])
  end

  # This API call allows you to register multiple Facebook users of your application into Comufy’s social CRM.
  # If these users were already registered into Comufy, their information will be updated.
  #
  # * (Array) +uids+ - The users you wish to add/update.
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
  def self.store_users(uids, tags)
    raise ArgumentError, "uids must be an Array. uids - #{uids.inspect}" unless uids and uids.is_a? Array
    raise ArgumentError, "tags must be an Array. tags - #{tags.inspect}" unless tags and tags.is_a? Array

    zipped = uids.zip(tags)
    data = {
        cd:              '88',
        token:           Comufyrails.config.access_token,
        applicationName: Comufyrails.config.app_name,
        accounts:        zipped.map { |uid, tagged | Hash[:account, { fbId: uid.to_s }, :tags, tagged] }
    }
    EM.synchrony do
      http = self.post(data)
      if http.response_header.status == 200
        message = JSON.parse(http.response)
        self.store_user_results(message, data)
      end
    end
  end

  # Sends a message with the description and content to the facebook id or id's specified, allowing multiple
  # options to be set concerning the privacy, and content of the message.
  #
  # * (String) +description+ - Description of the message. Useful to aggregate data in the Comufy dashboard. e.g. "Welcome".
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
  def self.send_facebook_message(description, content, uids, opts = {})
    raise ArgumentError, "You must include a description for the message." unless description
    raise ArgumentError, "You must include the content of the message." unless content
    raise ArgumentError, "Your must have a list of uids to send messages to." unless uids and uids.is_a? Array

    opts = symbolize_keys(opts)

    facebook_ids  = "FACEBOOK_ID=\"#{uids.join('\" OR FACEBOOK_ID=\"')}\""
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
      http = self.post(data)
      if http.response_header.status == 200
        message = JSON.parse(http.response)
        self.send_facebook_message_results(message, data)
      end
    end
  end

  private

  def self.store_user_results(message, data)
    case message["cd"]
      when 388 then
        p "388 - Success! - data = #{data} - message = #{message}."
      when 475 then
        p "475 - Invalid parameter provided. - data = #{data} - message = #{message}."
      when 617 then
        p "617 - Some of the tags passed are not registered. - data = #{data} - message = #{message}."
      when 632 then
        p "632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND - data = #{data} - message = #{message}."
      else
        p "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
    end
  end

  def self.send_facebook_message_results(message, data)
    case message["cd"]
      when 383 then
        p "383 - Success! - data = #{data} - message = #{message}."
      when 416 then
        p "416 - _ERROR_MSG_SEND_FAILED - data = #{data} - message = #{message}."
      when 475 then
        p "475 - Invalid parameters provided - data = #{data} - message = #{message}."
      when 551 then
        p "551 _ERROR_TAG_VALUE_NOT_FOUND - data = #{data} - message = #{message}."
      when 603 then
        p "603 - _ERROR_DOMAIN_APPLICATION_NAME_NOT_FOUND - data = #{data} - message = #{message}."
      when 607 then
        p "607 - _ERROR_UNAUTHORISED_ACTION - data = #{data} - message = #{message}."
      when 617 then
        p "617 - _ERROR_DOMAIN_APPLICATION_TAG_NOT_FOUND - data = #{data} - message = #{message}."
      when 648 then
        p "648 - _ERROR_FACEBOOK_APPLICATION_USER_NOT_FOUND - data = #{data} - message = #{message}."
      when 673 then
        p "673 - Invalid time exception - data = #{data} - message = #{message}."
      when 679 then
        p "679 - _ERROR_MALFORMED_TARGETING_EXPRESSION - data = #{data} - message = #{message}."
      else
        p "UNKNOWN RESPONSE - data = #{data} - message = #{message}."
    end
  end

  def self.post(data)
    url = Comufyrails.config.base_api_url
    body = { request: data.to_json }
    initheader = { 'Content-Type' => 'application/json' }
    EventMachine::HttpRequest.new(url).post(:body => body, :initheader => initheader)
  end

end
