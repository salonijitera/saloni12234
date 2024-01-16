class EmailService
  def send_reset_password_instructions(user, token)
    begin
      # Construct the reset password URL with the token
      reset_password_url = edit_password_url(user, reset_password_token: token)

      # Send the email using ActionMailer
      UserMailer.with(user: user, token: token, reset_password_url: reset_password_url)
                .reset_password_instructions
                .deliver_now

      { success: true, message: I18n.t('devise.passwords.send_instructions') }
    rescue => e
      # Log the error
      Rails.logger.error "Failed to send reset password instructions to #{user.email}: #{e.message}"

      { success: false, message: I18n.t('errors.messages.not_sent') }
    end
  end

  private

  def edit_password_url(user, params)
    edit_user_password_url(user, params).to_s
  end
end
