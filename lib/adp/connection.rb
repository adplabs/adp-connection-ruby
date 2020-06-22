require 'adp/connection/version'
require 'adp/access_token'
require 'adp/connection_configuration'
require 'adp/connection_exception'
require 'adp/api_connection'
require 'adp/api_connection_factory'
require 'adp/authorization_code_configuration'
require 'adp/authorization_code_connection'
require 'adp/client_credential_configuration'
require 'adp/client_credential_connection'
require 'adp/product/dto/user_info'
require 'adp/configuration'
require 'adp/marketplace'

module Adp
  module Connection
    class << self
      extend ::Forwardable

      def_delegators :configuration, *::Adp::Configuration::OPTIONS

      def configure
        yield configuration
      end

      def configuration
        @configuration ||= ::Adp::Configuration.new
      end
    end
  end
end
