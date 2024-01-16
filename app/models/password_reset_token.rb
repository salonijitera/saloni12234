class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :expires_at, presence: true
  validates :user_id, presence: true

  before_create :set_default_is_used

  private

  def set_default_is_used
    self.is_used ||= false
  end
end
