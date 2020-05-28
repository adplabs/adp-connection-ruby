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
        !access_token.nil? && Time.new < access_token.expires_on
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

        result = send_web_request(self.connection_configuration.tokenServerURL, data)

        if result["error"].nil? then
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

        data = send_web_request(product_url, data, authorization, "application/json", "GET")

        raise ConnectionException, "Connection error: #{data['error']}, #{data['error_description']}" unless data["error"].nil?

        return data
      end

      def send_web_request(url, data = {}, authorization = nil, content_type = "application/x-www-form-urlencoded", method = "POST")
        useragent = "adp-connection-ruby/#{Adp::Connection::VERSION}"
        uri = URI.parse(url)
        pem = Rails.application.credentials.fetch(:adp).fetch(:adp_ssl_certificate) || ENV.fetch("ADP_SSL_CERTIFICATE")
        key = Rails.application.credentials.fetch(:adp).fetch(:adp_ssl_key) || ENV.fetch("ADP_SSL_KEY")
        http = Net::HTTP.new(uri.host, uri.port)

        if pem
          http.use_ssl = true
          http.cert = OpenSSL::X509::Certificate.new(pem)
          http.key = OpenSSL::PKey::RSA.new(key, self.connection_configuration.sslKeyPass)
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        if !self.connection_configuration.sslCaPath.nil?
          http.cert_store = OpenSSL::X509::Store.new
          http.cert_store.add_file(self.connection_configuration.sslCaPath)
        end

        if method.eql?("POST")
          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data(data)
        else
          request = Net::HTTP::Get.new(uri.request_uri)
        end

        request.initialize_http_header({ "User-Agent" => useragent })
        request["Content-Type"] = content_type
        request["Authorization"] = authorization unless authorization.nil?

        JSON.parse(http.request(request).body)
      end

      private

      def log
        @_log ||= ::Logger.new(::STDOUT, level: ::Logger::DEBUG)
      end
    end
  end
end
