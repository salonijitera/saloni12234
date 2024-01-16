class EmailVerificationTokenService < BaseService
  def generate_email_verification_token(user:)
    token = SecureRandom.hex(10)
    expires_at = 24.hours.from_now

    email_verification_token = EmailVerificationToken.create!(
      token: token,
      expires_at: expires_at,
      user_id: user.id,
      is_used: false
    )

    token
  end
end
