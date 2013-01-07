# Comufyrails

This gem allows [Ruby on Rails](http://rubyonrails.org/) projects to connect with the
[Comufy service](http://www.comufy.com/). It uses asynchronous calls and separate rake tasks to communicate with
the Comufy API, allowing you to create, update your list of users as well as registering new tags and send
messages to your users.

## Installation

Add any of the lines to your application's Gemfile:

    gem 'comufyrails'
    gem 'comufyrails', :git => "git://github.com/plcstevens/comufyrails.git"
    gem 'comufyrails', :path => "/path/to/comufyrails/directory"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install comufyrails

As this uses EventMachine to perform asynchronous methods you need to use a web server that supports this, such
as [thin](http://code.macournoyer.com/thin/).

## Configuration

The gem requires configuration before being used. To get these values you must create an account with Comufy through
our Heroku service, or by yourself.

On Heroku you should add the Comufy add-on and follow the configuration steps it gives you. This will automatically
set the environment variables for your Comufy account that this gem will use. If you are not using our Heroku
service you will need to find another way to get these values, listed below.

If you are using this on your local development machine or elsewhere you have two ways to configure this gem. You
can get these values by using this heroku command below and looking for all values starting with 'COMUFY_'.

    heroku config

You can set the values in your config/environments/*.rb in the same manner you set rails-specific values.

```ruby
config.comufy_rails.app_name      = 'YOUR_APPLICATION_NAME'
config.comufy_rails.access_token  = 'YOUR_ACCESS_TOKEN'
config.comufy_rails.base_api_url  = 'COMUFY'
```

Alternatively you can set these in your environment/path.

```
COMUFY_APP_NAME     - Application name on Comufy, defaults to your Ruby on Rails application name.
COMUFY_TOKEN        - Token given to you by our Comufy Heroku service or from Comufy directly.
COMUFY_BASE_API_URL - Full HTTP address to connect to, defaults to our service.
```

## Usage

TODO: How to use this gem.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
