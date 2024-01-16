module PasswordResetService
  class ValidateInput
    include ActiveModel::Model

    attr_accessor :token, :password, :password_confirmation

    validate :input_fields_present

    private

    def input_fields_present
      errors.add(:token, "can't be blank") if token.blank?
      errors.add(:password, "can't be blank") if password.blank?
      errors.add(:password_confirmation, "can't be blank") if password_confirmation.blank?
    end
  end
end
