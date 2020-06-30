# frozen_string_literal: true

module Adp
  module Marketplace
    module Constants
      API_TOKEN_SCOPE = "ROLE_APPLICATION"

      ERROR_CODES = [
        UNAUTHORIZED_ERROR_CODE = "UNAUTHORIZED",
        FORBIDDEN_ERROR_CODE = "FORBIDDEN",
        UNKNOWN_ERROR_CODE = "UNKNOWN_ERROR",
        INVALID_RESPONSE = "INVALID_RESPONSE",
        USER_NOT_FOUND = "USER_NOT_FOUND"
      ].freeze
    end
  end
end
