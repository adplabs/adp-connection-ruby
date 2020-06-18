require "uri"
require "net/https"
require "base64"
require "json"

require_relative "connection_configuration"
require_relative "access_token"
require_relative "connection_exception"
require_relative "api_connection"
require_relative "client_credential_configuration"
require_relative "authorization_code_configuration"
require_relative "connection/version"

module Adp
  module Connection
    class ApiConnection
      attr_accessor :connection_configuration
      attr_accessor :token_expiration
      attr_accessor :state
      attr_accessor :access_token

      REQUEST_TYPE_MAPPING = {
        "POST"   => Net::HTTP::Post,
        "GET"    => Net::HTTP::Get,
        "DELETE" => Net::HTTP::Delete
      }.freeze

      def initialize(config = nil)
        self.connection_configuration = config
      end

      def connect
        if self.connection_configuration.nil?
          raise ConnectionException, "Configuration is empty or not found"
        end

        self.access_token = get_access_token
      end

      def disconnect
        self.access_token = nil
      end

      def connected?
        access_token = self.access_token
        access_token.present? && DateTime.current < access_token.expires_on
      end

      def get_access_token
        if connected?
          if self.connection_configuration.nil?
            raise ConnectionException, "Config error: Configuration is empty or not found"
          end

          if self.connection_configuration.grantType.nil?
            raise ConnectionException, "Config error: Grant Type is empty or not known"
          end

          if self.connection_configuration.tokenServerURL.nil?
            raise ConnectionException, "Config error: tokenServerURL is empty or not known"
          end

          if self.connection_configuration.clientID.nil?
            raise ConnectionException, "Config error: clientID is empty or not known"
          end

          if self.connection_configuration.clientSecret.nil?
            raise ConnectionException, "Config error: clientSecret is empty or not known"
          end
        end

        data = {
          "client_id" => self.connection_configuration.clientID,
          "client_secret" => self.connection_configuration.clientSecret,
          "grant_type" => self.connection_configuration.grantType
        }

        result = send_web_request(self.connection_configuration.tokenServerURL, data, content_type: "application/x-www-form-urlencoded", query_method: "POST")

        if result["error"].nil?
          token = AccessToken.new(result)
        else
          raise ConnectionException, "Connection error: #{result['error_description']}"
        end

        token
      end

      def get_adp_data(product_url)
        raise ConnectionException, "Connection error: can't get data, not connected" if (self.access_token.nil? || !connected?)

        authorization = "#{self.access_token.token_type} #{self.access_token.token}"
        data = {
          "client_id" => self.connection_configuration.clientID,
          "client_secret" => self.connection_configuration.clientSecret,
          "grant_type" => self.connection_configuration.grantType,
          "code" => self.connection_configuration.authorizationCode,
          "redirect_uri" => self.connection_configuration.redirectURL
        }

        data = send_web_request(product_url, data, authorization: authorization, content_type: "application/json", query_method: "GET")

        raise ConnectionException, "Connection error: #{data['error']}, #{data['error_description']}" unless data["error"].nil?

        return data
      end

      def send_web_request(url, data = {}, authorization: nil, content_type:, query_method:, options: {})
        useragent = "adp-connection-ruby/#{Adp::Connection::VERSION}"
        uri = URI.parse(url)
        ssl_certificate = Rails.application.credentials.fetch(:adp).fetch(:adp_ssl_certificate) || ENV.fetch("ADP_SSL_CERTIFICATE")
        ssl_key = Rails.application.credentials.fetch(:adp).fetch(:adp_ssl_key) || ENV.fetch("ADP_SSL_KEY")
        http = Net::HTTP.new(uri.host, uri.port)

        if ssl_certificate.present?
          http.use_ssl = true
          http.cert = OpenSSL::X509::Certificate.new(ssl_certificate)
          http.key = OpenSSL::PKey::RSA.new(ssl_key, self.connection_configuration.sslKeyPass)
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        if self.connection_configuration.sslCaPath.present?
          http.cert_store = OpenSSL::X509::Store.new
          http.cert_store.add_file(self.connection_configuration.sslCaPath)
        end

        request = REQUEST_TYPE_MAPPING.fetch(query_method).new(uri.request_uri)

        if content_type == "application/x-www-form-urlencoded"
          request.set_form_data(data)
        elsif content_type == "application/json"
          request.body = data.to_json
        end

        request.initialize_http_header({ "User-Agent" => useragent })
        request["Content-Type"] = content_type
        request["Authorization"] = authorization if authorization.present?
        request["Accept"] = "application/json;masked=false" if options.fetch(:unmasked, false)

        response_body = http.request(request).body
        response_body.nil? ? nil : JSON.parse(response_body)
      end

      private

      def log
        @_log ||= ::Logger.new(::STDOUT, level: ::Logger::DEBUG)
      end
    end
  end
end
