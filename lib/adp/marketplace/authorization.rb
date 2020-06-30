# frozen_string_literal: true

require 'adp/marketplace/constants'
require 'adp/connection'
require 'omniauth-oauth2'

module Adp
  module Marketplace
    module Authorization
      def access_token
        oauth_client.client_credentials.get_token({ scope: ::Adp::Marketplace::Constants::API_TOKEN_SCOPE }).token
      end

      private

      def oauth_client
        ::OAuth2::Client.new(
          ::Adp::Connection.marketplace_client_id,
          ::Adp::Connection.marketplace_client_secret,
          {
            token_url: ::Adp::Connection.marketplace_token_url,
            site: ::Adp::Connection.marketplace_api_endpoint
          }
        )
      end
    end
  end
end
