require 'adp/connection_configuration'

module Adp
  module Connection

    class ClientCredentialConfiguration < ConnectionConfiguration
      attr_accessor :grantType

      def initialize(config)
        super

        self.clientID = config["clientID"] || Rails.application.credentials.fetch(:adp).fetch(:adp_dc_client_id) || ENV.fetch("ADP_DC_CLIENT_ID")
        self.clientSecret = config["clientSecret"] || Rails.application.credentials.fetch(:adp).fetch(:adp_dc_client_secret) || ENV.fetch("ADP_DC_CLIENT_SECRET")
        self.grantType = :client_credentials
      end
    end
  end
end
