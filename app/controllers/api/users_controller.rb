class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      email = params.require(:email)
      result = Services::PasswordResetService.request_password_reset(email)

      if result[:error].present?
        if result[:error] == 'Email not registered'
          render json: { message: result[:error] }, status: :not_found
        else
          render json: { message: result[:error] }, status: :unprocessable_entity
        end
      else
        render json: { status: 200, message: result[:message] }, status: :ok
      end
    rescue ActionController::ParameterMissing => e
      render json: { message: e.message }, status: :bad_request
    end
  end
end
