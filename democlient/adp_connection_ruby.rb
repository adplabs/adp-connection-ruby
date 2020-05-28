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


  before do

    # request.path_info = '/foo/bar/baz'
  end

  after do
      # erb :welcome, :locals => { :view_bag => results }
  end

  get "/" do
    results[:message] = nil
    erb :welcome, :locals => { :view_bag => results }
  end

  get '/client_credentials' do
    results[:auth_type] = :client_credentials
    results[:message] = nil

    erb :client_credentials, :locals => { :view_bag => results }
  end

  get '/client_credentials/logout' do
      session["ClientCredential"] = nil
      results[:message] = nil
      results[:auth_type] = :client_credentials
      results[:userinfo] = nil

      erb :client_credentials, :locals => { :view_bag => results }
  end

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

  get '/authorization_code' do
    results[:message] = nil
    results[:auth_type] = :authorization_code
    erb :authorization_code, :locals => { :view_bag => results}
  end

  get '/authorization_code/logout' do
    session["AuthorizationCode"] = nil
    results[:message] = nil
    results[:auth_type] = :authorization_code
    results[:userinfo] = nil

    erb :authorization_code, :locals => { :view_bag => results }
  end

  get '/authorization_code/login' do
    connection = session["AuthorizationCode"]
    results[:message] = nil
    authorizationurl = nil
    results[:userinfo] = nil

    if (connection.nil?)

      # get new connection configuration
      # YAML config object placed in yaml configuration files
      config = YAML.load_file('config/authorizationcode_config.yml');

      if (config.nil? || !config) then
        results[:message] = "Unable to load configuration settings from file (config/authorizationcode_config.yml)"
      else
        begin
          authorizationcode_config = Adp::Connection::AuthorizationCodeConfiguration.new(config);

          Log.debug("Configuration from file was #{authorizationcode_config}")
          connection = Adp::Connection::ApiConnectionFactory::createConnection(authorizationcode_config)

          Log.debug("Connection object was #{connection}")
          session["AuthorizationCode"] = connection;
        end
      end
    end

    authorizationurl = connection.get_authorization_url

    Log.debug("Redirecting to authorizationurl #{authorizationurl} from connection #{connection}")

    results[:auth_type] = :authorization_code
    results[:authorizationurl] = authorizationurl

    redirect authorizationurl unless authorizationurl.nil?

    erb :authorization_code, :locals => { :view_bag => results}
  end

  get '/callback' do
    results[:auth_type] = :authorization_code
    results[:message] = nil

    if !params[:error].nil?
      results[:message] = "Callback Error: #{params[:error]}"
    else
      if params[:code].nil?
        results[:message] = "Callback Error: ﻿Unauthorized"
      else
        connection = session["AuthorizationCode"]
        unless connection.nil?
          connection.connection_configuration.authorizationCode = params[:code]
          Log.debug("Got authorization code #{connection.connection_configuration.authorizationCode}")
        end
      end
    end
    Log.debug("Back to callback with #{params[:code]}")
    erb :authorization_code, :locals => { :view_bag => results}
  end

  get '/authorization_code/get_token' do
    results[:auth_type] = :authorization_code
    results[:message] = nil
    results[:userinfo] = nil
    connection = session["AuthorizationCode"]

    begin
      unless connection.nil? || connection.connection_configuration.authorizationCode.nil?
        connection.connect()
        session["AuthorizationCode"] = connection
      end
    rescue Adp::Connection::ConnectionException
      e = env['sinatra.error']
      results[:message] = "Connection error: The requested token could not be retrieved"
    end

    erb :authorization_code, :locals => { :view_bag => results}
  end

  get '/authorization_code/get_userinfo' do
    results[:auth_type] = :authorization_code
    results[:message] = nil
    connection = session["AuthorizationCode"]

    begin
      Log.debug("Do we have a connection object? #{connection}")
      unless connection.nil? || connection.connection_configuration.authorizationCode.nil?
        Log.debug("Check if we are connected: #{connection.access_token}")
        if (connection.connected?)
          Log.debug("Getting helper object")
            helper = Adp::Connection::UserInfoHelper.new(connection)
          Log.debug("getting userinfo using helper object")
            json_data = helper.get_user_info()
            results[:userinfo] = Adp::Connection::UserInfo.new(json_data)

            Log.debug("Got user info #{json_data}")
        end
      end
      Log.debug("Done getting userinfo #{results[:userinfo]}")
    rescue Adp::Connection::ConnectionException
      e = env['sinatra.error']
      results[:message] = "Connection error: #{e}"
    end

    erb :authorization_code, :locals => { :view_bag => results}
  end
end
