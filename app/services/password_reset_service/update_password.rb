module PasswordResetService
  class UpdatePassword
    def self.call(user, new_password)
      user.password_hash = BCrypt::Password.create(new_password)
      user.save!
    rescue ActiveRecord::RecordInvalid => e
      # Handle saving errors here, e.g., log to a file or send to an error tracking service
      raise e
    end
  end
end
