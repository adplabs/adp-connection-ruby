module Adp
  module Connection

    class ConnectionConfiguration

      attr_accessor :clientID
      attr_accessor :clientSecret
      attr_accessor :sslCertPath
      attr_accessor :sslCaPath
      attr_accessor :sslKeyPath
      attr_accessor :sslKeyPass
      attr_accessor :tokenServerURL
      attr_accessor :apiRequestURL
      attr_accessor :accessScope
      attr_accessor :grantType


      def initialize( config )

        self.clientID = config["clientID"] || ENV.fetch("ADP_SSO_CLIENT_ID")
        self.clientSecret = config["clientSecret"] || ENV.fetch("ADP_SSO_CLIENT_SECRET")
        self.sslCertPath = config["sslCertPath"]
        self.sslCaPath = config["sslCaPath"]
        self.sslKeyPath = config["sslKeyPath"]
        self.sslKeyPass = config["sslKeyPass"]
        self.tokenServerURL = config["tokenServerURL"]
        self.apiRequestURL = config["apiRequestURL"]
        self.accessScope = config["accessScope"]
      end
    end
  end
end