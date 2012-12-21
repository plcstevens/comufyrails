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
      results = []

      resp = EventMachine::HttpRequest.new(Comufyrails.config.base_api_url).post(
          :body       => { request: data.to_json },
          :initheader => { 'Content-Type' => 'application/json' })
      results.push resp.response

      p results # all completed requests
      EventMachine.stop
    end

    p "Has request happened yet?"
    p "I wonder whats going on"
    [1,2,3,4,5,6,7,8,9,10].each do |number|
      p number
    end
  end

end
