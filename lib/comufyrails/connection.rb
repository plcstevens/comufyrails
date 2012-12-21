require "em-synchrony"
require "em-synchrony/em-http"
require "em-synchrony/fiber_iterator"

module Comufyrails::Connection

  # aim of this module is to will be to allow sync/async connections to be sent to our heroku servers
  # to be processed and then returned (or the error message returned)

  # with this in mind, we will probably be using https://github.com/igrigorik/em-synchrony
  # with post and post requests to send and receive data. It'll use the information generated from the Railtie
  # to know what/who is sending and to where.

  def store_user(uid, tags)
    data = {
        token:           Comufyrails.config.access_token,
        cd:              '88',
        applicationName: Comufyrails.config.app_name,
        accounts:        [{
                              account: { fbId: uid },
                              tags:    tags
                          }]
    }

    EM.synchrony do
      results = []

      EM::Synchrony::FiberIterator.new(Comufyrails.config.base_api_url, 1).each do |url|
        resp = EventMachine::HttpRequest.new(url).post(:body => { request: data.to_json }, :initheader => { 'Content-Type' => 'application/json' })
        results.push resp.response
      end

      p results # all completed requests
      EventMachine.stop
    end
  end

end
