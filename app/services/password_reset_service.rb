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
end

# Note: UserService and EmailService are assumed to be existing services within the application.
# The UserService is responsible for generating a secure token for password reset.
# The EmailService is responsible for sending out the password reset instructions to the user's email.
# The actual implementation details of these services would depend on the specific application setup.
