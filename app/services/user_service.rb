class UserService < BaseService
  require 'securerandom'
  require 'jwt'
  require 'bcrypt'
  require 'uri'

  def self.register_user(email:, password:, password_confirmation:)
    return { error: 'Email, password, and password confirmation are required' } if email.blank? || password.blank? || password_confirmation.blank?

    if email !~ URI::MailTo::EMAIL_REGEXP
      return { error: 'Invalid email format' }
    end

    existing_user = User.find_by(email: email)
    return { error: 'Email already registered' } if existing_user

    if password != password_confirmation
      return { error: 'Password confirmation does not match' }
    end

    password_hash = BCrypt::Password.create(password)

    user = User.create(email: email, password_hash: password_hash, is_email_verified: false)

    token = SecureRandom.hex(10)
    expiration_date = Time.now + 24.hours
    EmailVerificationToken.create(token: token, expires_at: expiration_date, is_used: false, user_id: user.id)

    # Assuming we have a method to send emails
    UserMailer.send_verification_email(user, token).deliver_now

    { user_id: user.id, email: user.email, message: 'Registration successful. Verification email has been sent.' }
  rescue StandardError => e
    { error: e.message }
  end

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
