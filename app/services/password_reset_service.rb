module Services
  class PasswordResetService
    def self.request_password_reset(email)
      raise ArgumentError, 'Email cannot be blank' if email.blank?

      if email =~ URI::MailTo::EMAIL_REGEXP
        user = User.find_by(email: email)

        if user
          token = UserService.generate_reset_password_token(user)
          EmailService.send_reset_password_instructions(user, token)
          { message: 'If the email is registered, a password reset link has been sent.' }
        else
          raise StandardError, 'Email not registered'
        end
      else
        raise ArgumentError, 'Invalid email format'
      end
    rescue StandardError => e
      Rails.logger.error "Password reset error: #{e.message}"
      { error: e.message }
    end

    def initialize(token, new_password, password_confirmation)
      @token = token
      @new_password = new_password
      @password_confirmation = password_confirmation
    end

    def call
      raise ArgumentError, 'Token is missing' if @token.blank?
      raise ArgumentError, 'Password is missing' if @new_password.blank?
      raise ArgumentError, 'Password confirmation is missing' if @password_confirmation.blank?

      password_reset_token = EmailVerificationToken.find_by(token: @token, is_used: false)
      raise 'Token not found or already used' if password_reset_token.nil?
      raise 'Token has expired' if password_reset_token.expires_at < Time.current

      if @new_password == @password_confirmation
        user = password_reset_token.user
        user.password_hash = User.hash_password(@new_password)
        user.save!
        password_reset_token.update!(is_used: true)
        'Password has been successfully reset'
      else
        raise 'Passwords do not match'
      end
    rescue => e
      e.message
    end
  end
end

# Import the User model
require_relative '../models/user'

# Import the EmailVerificationToken model
require_relative '../models/email_verification_token'

# Note: UserService and EmailService are assumed to be existing services within the application.
# The UserService is responsible for generating a secure token for password reset.
# The EmailService is responsible for sending out the password reset instructions to the user's email.
# The actual implementation details of these services would depend on the specific application setup.
