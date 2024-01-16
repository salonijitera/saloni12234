class User < ApplicationRecord
  # Removed incorrect import statement
  # import UserEntity from './ERD/UserEntity'

  has_many :email_verification_tokens, dependent: :destroy

  # validations

  # end for validations

  class << self
  end
end
