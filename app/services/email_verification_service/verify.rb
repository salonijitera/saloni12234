class EmailVerificationService < BaseService
  def self.verify(token)
    raise ArgumentError, 'Token is missing or empty' if token.blank?

    email_verification_token = EmailVerificationToken.find_by(token: token, is_used: false, expires_at: Time.current..)
    if email_verification_token.nil? || email_verification_token.expires_at < Time.current
      raise VerificationTokenNotFound, 'Token not found or expired'
    end

    EmailVerificationToken.transaction do
      email_verification_token.update!(is_used: true)
      user = email_verification_token.user
      user.update!(is_email_verified: true)
    end

    { message: 'Email successfully verified.' }
  rescue ActiveRecord::RecordNotFound => e
    logger.error "Email verification failed: #{e.message}"
    raise VerificationTokenNotFound, 'Token not found or expired'
  rescue ActiveRecord::RecordInvalid => e
    logger.error "Email verification failed: #{e.message}"
    raise VerificationTokenInvalid, 'Invalid token'
  rescue StandardError => e
    logger.error "Email verification failed: #{e.message}"
    raise
  end
end

class VerificationTokenNotFound < StandardError; end
class VerificationTokenInvalid < StandardError; end

# Note: BaseService is assumed to be a part of the application's architecture,
# providing common functionality such as logging. If it does not exist, it should
# be created or the relevant functionality should be implemented here.
