module Adp
  module Connection

    class AccessToken
      attr_accessor :token
      attr_accessor :token_type
      attr_accessor :scope
      attr_accessor :expires_on
      attr_accessor :token
      attr_accessor :_expires_in

      # @return [Object]
      def initialize(config = nil)

        unless config.nil?
          self.token = config["access_token"]
          self.token_type = config["token_type"]
          self.scope = config["scope"]
          self.expires_in = config["expires_in"]
        end
      end

      # @return [Object]
      def expires_in=(value)
        unless value.nil?
          self._expires_in = value
          self.expires_on = DateTime.current + self._expires_in.to_i.seconds
        end
        self.expires_on
      end

      # @return [Object]
      def expires_in
        return self._expires_in
      end

      def is_valid?
        return true;
      end
    end
  end
end


