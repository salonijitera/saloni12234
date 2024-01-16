class UserService < BaseService
  require 'jwt'

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

    private

    def generate_token(user)
      # Assuming we have a method to generate a token
      JWT.encode({ user_id: user.id }, 'your_secret', 'HS256')
    end
  end
end
