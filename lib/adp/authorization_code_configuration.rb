require 'adp/connection_configuration'

module Adp
  module Connection

    class AuthorizationCodeConfiguration < ConnectionConfiguration

      attr_accessor :authorizationCode
      attr_accessor :baseAuthorizationURL
      attr_accessor :redirectURL
      attr_accessor :responseType
      attr_accessor :scope
      attr_accessor :state


      def initialize( config )
          super

          self.clientID = config["clientID"] || Rails.application.credentials.fetch(:adp).fetch(:adp_sso_client_id) || ENV.fetch("ADP_SSO_CLIENT_ID")
          self.clientSecret = config["clientSecret"] || Rails.application.credentials.fetch(:adp).fetch(:adp_sso_client_secret) || ENV.fetch("ADP_SSO_CLIENT_SECRET")
          self.authorizationCode = config["authorizationCode"]
          self.baseAuthorizationURL = config["baseAuthorizationURL"]
          self.redirectURL = config["redirectURL"]
          self.responseType = config["responseType"]
          self.scope = config["scope"]
          self.state = config["state"]
          self.grantType = "authorization_code"
      end
    end
  end
end