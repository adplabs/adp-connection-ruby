# Environment variables

Please use rails encrypted credentials (per environment). Example:

`rails credentials:edit --environment development`
```
adp:
  adp_sso_client_id: abc
  adp_sso_client_secret: abc
  adp_ssl_certificate: abc
  adp_ssl_key: abc
```

If keys are present in the encrypted credentials, but their values are nil, it will fall back to the env vars. If keys aren't present in the credentials at all though, it will throw an exception. 

`adp_ssl_certificate` (env var `ADP_SSL_CERTIFICATE`) - for the SSL certificate (.pem)

`adp_ssl_key` (env var `ADP_SSL_KEY`) - for the SSL certificate key

## SSO

`adp_sso_client_id` (env var `ADP_SSO_CLIENT_ID`) - clientID in ADP docs

`adp_sso_client_secret` (env var `ADP_SSO_CLIENT_SECRET`) - clientSecret in ADP docs


# ADP Connection Client Library for Ruby

The ADP Client Connection Library is intended to simplify and aid the process of authenticating, authorizing and connecting to the ADP Marketplace API Gateway. The Library includes a sample application that can be run out-of-the-box to connect to the ADP Marketplace API **test** gateway.

### Version
0.1.5


## Installation

There are two ways of installing and using this library:

  - Clone the repo from Github: This allows you to access the raw source code of the library as well as provide the ability to run the sample demo client application and view the Library documentation
  - Install & use gem from RubyGems.org(https://rubygems.org/gems/adp-connection): When you are ready to use the library in your own application use this method to install it using gem/bundle


**Clone from Github**

You can either use the links on Github or the command line git instructions below to clone the repo.

```sh

$ git clone https://github.com/adplabs/adp-connection-ruby.git adp-connection-ruby

```

followed by

```sh

$ cd adp-connection-ruby
$ gem install bundler
$ bundle install
$ rake -T
$ rake install:local

```

*Run the sample demo client app*

```sh

$ cd ./democlient
$ bundle install
$ rackup

```

This starts an HTTP server on port 8889 (this port must be unused to run the sample application). You can point your browser to http://localhost:8889. The sample app allows you to connect to the ADP test API Gateway using the **client_credentials** and **authorization_code** grant types. For the **authorization_code** connection, you will be asked to provide an ADP username (MKPLDEMO) and password (marketplace1).

***


**Install & use gem from package manager (RubyGems.org)**

Add this line to your application's Gemfile:

```ruby

gem 'adp-connection'

```

And then execute:

```sh
    
    $ bundle install

```

Or install it yourself as:

```sh

    $ gem install adp-connection

```

## Usage

Start using the library by requiring the gem in your ruby files

```ruby

require 'adp/connection'

```


## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

A demo client is included that uses the adp-connection gem. Check it out.


## Examples
### Create Client Credentials ADP Connection

Here is a Sinatra (http://www.sinatrarb.com/) example

```ruby

require 'yaml'
require 'tilt/erb'
require 'logger'
require 'adp/connection'

clientcredential_config = YAML.load(ERB.new(File.read('config/clientcredential_config.yml')).result)
authorizationcode_config = YAML.load(ERB.new(File.read('config/authorizationcode_config.yml')).result)

configure do
  Log = Logger.new(STDOUT);
  #Logger.new("sinatra.log")
  Log.level  = Logger::DEBUG
end

class AdpConnectionRuby < Sinatra::Base

  enable :sessions
  set :public_folder => "public", :static => true

  #set :protection, :session => true
  set :port, 8889

  results = {
      :message =>  "Welcome",
      :auth_type => nil
  }

  get '/client_credentials/login' do
    results[:auth_type] = :client_credentials
    results[:message] = nil
    connection = session["ClientCredential"]
    results[:userinfo] = nil

    if (connection.nil?)

      # get new connection configuration
      # YAML config object placed in yaml configuration files
      config = YAML.load_file('config/clientcredential_config.yml');

      if (!config || config.nil?)
        results[:message] = "Unable to load configuration settings from file (config/clientcredential_config.yml)"
      else
        begin
          clientcredential_config = Adp::Connection::ClientCredentialConfiguration.new(config);

          connection = Adp::Connection::ApiConnectionFactory::createConnection(clientcredential_config)

          connection.connect();

          if (!connection.connected?)
            results[:message] = "Error attempting to establish a connection"
            Log.error "Not connected"
          else
            Log.debug("Connected and ready for getting data");
            session["ClientCredential"] = connection;
          end
        end
      end
    end
    erb :client_credentials, :locals => { :view_bag => results }
  end

end


```


## API Documentation ##

Documentation on the individual API calls provided by the library is automatically generated from the library code. To generate the documentation, please complete the following steps:

```
# not applicable
```


## Tests ##

Automated unit tests are available in tests folder. To run the tests, please complete the following steps.

```
rake spec
```

The above will also display test results. 

## Code Coverage ##

```
# not applicable
```

## Dependencies ##

This library has the following **install** dependencies. These are installed automatically as part of the 'bundle install' or 'gem install adp-connection' if they don't exist.

* json

This library has the following **development/test** dependencies. These are installed automatically as part of the 'bundle install' if they don't exist.

* bundler
* rake
* rspec

## Contributing ##

To contribute to the library, please generate a pull request. Before generating the pull request, please insure the following:

1. Appropriate unit tests have been updated or created.
2. Code coverage on the unit tests must be no less than 95%.
3. Your code updates have been fully tested.
4. Update README.md and API documentation as appropriate.

Author: Junior Napier

## License ##

The gem is available as open source under the terms of the Apache License 2.0 (http://www.apache.org/licenses/LICENSE-2.0).

