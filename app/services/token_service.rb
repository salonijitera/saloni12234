class TokenService < BaseService
  def self.generate_token(user:)
    raise ArgumentError, 'User cannot be nil' if user.nil?

    CustomAccessToken.create!(
      user: user,
      expires_at: Time.current + 2.weeks, # Set the token to expire in 2 weeks
      token: SecureRandom.hex(10) # Generate a random token
    )
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, e.message
  end

  private

  # Add any additional helper methods below
end

