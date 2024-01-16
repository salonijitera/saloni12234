# frozen_string_literal: true

module PasswordResetService
  class InvalidateToken
    def self.call(password_reset_token)
      password_reset_token.update(is_used: true)
    rescue StandardError => e
      # Handle exceptions, e.g., log error
    end
  end
end
