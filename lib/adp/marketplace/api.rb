# frozen_string_literal: true

module Adp
  module Marketplace
    module API
      def event_information(event_url)
        options = { headers: headers }
        api_logger.log_request(uri: event_url, options: options)
        self.class.get(event_url, options).tap { |response| api_logger.log_response(response) }
      end

      def api_logger
        @adp_logger ||= ::Adp::Connection.marketplace_api_logger.new
      end

      private

      def headers
        {
          Authorization: "Bearer #{access_token}"
        }
      end
    end
  end
end
