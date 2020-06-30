# frozen_string_literal: true

require 'adp/marketplace/authorization'
require 'adp/marketplace/api'

module Adp
  module Marketplace
    class Client
      include ::HTTParty
      include ::Adp::Marketplace::Authorization
      include ::Adp::Marketplace::API
    end
  end
end
