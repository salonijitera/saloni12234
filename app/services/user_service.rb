class UserService < BaseService
  require 'securerandom'
  require 'jwt'
  require 'bcrypt'

  class << self
    def authenticate_user(email:, password:)
      user = User.find_by(email: email)

      if user.nil?
        return { error: 'User not found' }
      elsif !user.is_email_verified
        return { error: 'Email not verified' }
      elsif !BCrypt::Password.new(user.password_hash).is_password?(password)
        return { error: 'Incorrect password' }
      else
        # Generate a session token or JWT token for the user
        token = generate_token(user)
        return { token: token, user: user }
      end
    rescue StandardError => e
      return { error: e.message }
    end

    def generate_reset_password_token(email)
      user = User.find_by(email: email)

      if user
        token = SecureRandom.urlsafe_base64
        expires_at = 2.hours.from_now

        email_verification_token = user.email_verification_tokens.create(
          token: token,
          expires_at: expires_at,
          is_used: false
        )

        if email_verification_token.persisted?
          # Here you would send the email with the token
          # For example: UserMailer.send_reset_password_instructions(user, token).deliver_now
          return 'If your email is registered, a password reset link has been sent.'
        end
      end

      'If your email is registered, a password reset link has been sent.'
    end

    private

    def generate_token(user)
      # Assuming we have a method to generate a token
      JWT.encode({ user_id: user.id }, 'your_secret', 'HS256')
    end
  end
end
