module PasswordResetService
  class FindToken
    def initialize(token)
      @token = token
    end

    def call
      password_reset_token = EmailVerificationToken.find_by(token: @token, is_used: false)
      raise 'Token not found or already used' if password_reset_token.nil?
      raise 'Token expired' if password_reset_token.expires_at < Time.current

      password_reset_token
    end

    private

    attr_reader :token
  end
end
