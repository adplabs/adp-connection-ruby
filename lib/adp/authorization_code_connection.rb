require 'securerandom'
require 'adp/api_connection'

module Adp
  module Connection

    class AuthorizationCodeConnection < ApiConnection
      attr_accessor :state

      def get_authorization_url


        if self.connection_configuration.nil?
          raise ConnectionException, "Config error: Configuration is empty or not found"
        end
        if (self.connection_configuration.baseAuthorizationURL.nil?)
          raise ConnectionException, "Config error: baseAuthorizationURL is empty or not known"
        end
        if (self.connection_configuration.clientID.nil?)
          raise ConnectionException, "Config error: clientID is empty or not known"
        end
        if (self.connection_configuration.responseType.nil?)
          raise ConnectionException, "Config error: responseType is empty or not known"
        end
        if (self.connection_configuration.clientSecret.nil?)
          raise ConnectionException, "Config error: clientSecret is empty or not known"
        end
        if (self.connection_configuration.redirectURL.nil?)
          raise ConnectionException, "Config error: redirectURL is empty or not known"
        end

        self.state = SecureRandom.uuid

        url = self.connection_configuration.baseAuthorizationURL + '?' + URI.encode_www_form(
            :client_id => self.connection_configuration.clientID,
            :response_type => self.connection_configuration.responseType,
            :redirect_uri => self.connection_configuration.redirectURL,
            :scope => 'openid',
            :state => self.state
        )

        log.debug("URL was #{url}")
        return url
      end

      def get_access_token
        token = self.access_token;
        result = nil;

        if connected?

          if self.connection_configuration.nil?
            raise ConnectionException, "Config error: Configuration is empty or not found"
          end
          if (self.connection_configuration.grantType.nil?)
            raise ConnectionException, "Config error: grantType is empty or not known"
          end
          if (self.connection_configuration.redirectURL.nil?)
            raise ConnectionException, "Config error: redirectURL is empty or not known"
          end
          if (self.connection_configuration.clientID.nil?)
            raise ConnectionException, "Config error: clientID is empty or not known"
          end
          if (self.connection_configuration.clientSecret.nil?)
            raise ConnectionException, "Config error: clientSecret is empty or not known"
          end
          if (self.connection_configuration.authorizationCode.nil?)
            raise ConnectionException, "Config error: authorizationCode is empty or not known"
          end
        end

        log.debug("connection configutration: #{self.connection_configuration.inspect}")

        data = {
            "client_id" => self.connection_configuration.clientID,
            "client_secret" => self.connection_configuration.clientSecret,
            "grant_type" => self.connection_configuration.grantType,
            "code" => self.connection_configuration.authorizationCode,
            "redirect_uri" => self.connection_configuration.redirectURL
        };

        result = send_web_request(self.connection_configuration.tokenServerURL, data )

        if result["error"].nil? then
          token = AccessToken.new(result)
        else
          self.access_token = nil
          raise ConnectionException, "Connection error: #{result["error"]} #{result['error_description']}"
        end

        log.debug("Results from request was #{result}")

        token
      end
    end
  end
end