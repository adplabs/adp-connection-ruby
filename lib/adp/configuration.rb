require 'adp/null_logger'

module Adp
  class Configuration
    OPTIONS = %i(api_logger ssl_certificate ssl_key marketplace_client_id marketplace_client_secret
                 marketplace_api_logger marketplace_api_endpoint marketplace_token_url).freeze

    attr_accessor(*OPTIONS)

    def api_logger
      @api_logger || ::Adp::NullLogger
    end

    def marketplace_api_logger
      @marketplace_api_logger || ::Adp::NullLogger
    end
  end
end
