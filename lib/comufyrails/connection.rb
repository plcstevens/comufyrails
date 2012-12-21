
module Comufyrails::Connection

  # aim of this module is to will be to allow sync/async connections to be sent to our heroku servers
  # to be processed and then returned (or the error message returned)

  # with this in mind, we will probably be using https://github.com/igrigorik/em-synchrony
  # with apost and post requests to send and receive data. It'll use the information generated from the Railtie
  # to know what/who is sending and to where.
end
