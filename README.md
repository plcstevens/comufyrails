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

Or install it yourself:

    $ gem install comufyrails


## Web servers

As this gem uses EventMachine to perform asynchronous methods you need to use a web server that supports EventMachine,
such as [thin](http://code.macournoyer.com/thin/).

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
config.comufy_rails.url  = 'COMUFY'
```

Alternatively you can set these in your environment/path.

```
COMUFY_APP_NAME     - Application name on Comufy, defaults to your Ruby on Rails application name.
COMUFY_TOKEN        - Token given to you by our Comufy Heroku service or from Comufy directly.
COMUFY_URL - Full HTTP address to connect to, defaults to our service.
```

## Usage

In its current iteration you can use this gem to send information to Comufy, allowing you to add users, update data
on the users and send messages/notifications to your users via your own service.

If you have your own user database, and wish to keep the Comufy database in sync with it, you can use the observer
behaviour for your model and asynchronously send the data to Comufy.

```ruby
class UserObserver < ActiveRecord::Observer

  def after_save(user)
    data = { dob: user.dob.to_comufy_time, fact: user.fact }
    Comufyrails::Connection.store_user(user.facebook_id, data)
  end
end
```

Or you can place the code in your controllers. As this method is asynchronous it will not block and affect
performance. It should be noted that these methods return their results to the logs.

```ruby
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        Comufyrails::Connection.store_user(user.facebook_id, { dob: user.dob.to_comufy_time, fact: user.fact })
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

There are also a number of methods that are added to your rake environment, for one-time actions. These include
the ability to add/remove tags for users of your applications.

```bash
$ bundle exec rake comufy:tag["DOB", "DATE"]
```

This will run a blocking call to register this tag with your application, informing you if it was successful or not.
It will use the configuration exactly as your Rails application will, so if you need to run it as production, you
merely have to add RAILS_ENV=production or -e production.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
