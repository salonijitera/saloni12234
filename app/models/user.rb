
class User < ApplicationRecord
  # import UserEntity from 'ERD/UserEntity'; # Removed incorrect import statement

  has_many :email_verification_tokens, dependent: :destroy

  # validations

  # end for validations

  class << self
  end
end
