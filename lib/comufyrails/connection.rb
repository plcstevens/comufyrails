require "em-synchrony"
require "em-synchrony/em-http"
require "em-synchrony/fiber_iterator"

module Comufyrails::Connection

  # aim of this module is to will be to allow sync/async connections to be sent to our heroku servers
  # to be processed and then returned (or the error message returned)

  # with this in mind, we will probably be using https://github.com/igrigorik/em-synchrony
  # with post and post requests to send and receive data. It'll use the information generated from the Railtie
  # to know what/who is sending and to where.

  # working example
  def self.store_user(uid, tags)
    data = {
        cd:              '88',
        token:           Comufyrails.config.access_token,
        applicationName: Comufyrails.config.app_name,
        accounts:        [{
                              account: { fbId: uid },
                              tags:    tags
                          }]
    }

    EM.synchrony do
      url = Comufyrails.config.base_api_url

      resp = EventMachine::HttpRequest.new(url).post(
          :body       => { request: data.to_json },
          :initheader => { 'Content-Type' => 'application/json' })
      results = JSON.parse(resp.response)

      case results['cd']
        when 388 then
          p "388 - Success! - data = #{data} - message = #{results}."
        when 475 then
          p "475 - Invalid parameter provided. - data = #{data} - message = #{results}."
        when 617 then
          p "617 - Some of the tags passed are not registered. - data = #{data} - message = #{results}."
        when 632 then
          p "632 - _ERROR_FACEBOOK_PAGE_NOT_FOUND - data = #{data} - message = #{results}."
        else
          p "UNKNOWN RESPONSE - data = #{data} - message = #{results}."
      end
    end
  end

end
