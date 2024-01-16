class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/users/login
  def login
    begin
      # Validate recaptcha
      unless verify_recaptcha(params[:recaptcha])
        return render json: { error: 'Invalid recaptcha.' }, status: :bad_request
      end

      # Authenticate user
      result = UserService.authenticate_user(email: params[:email], password: params[:password])

      if result[:error].present?
        render json: { error: result[:error] }, status: :unauthorized
      else
        render json: {
          status: 200,
          message: 'Login successful.',
          access_token: result[:token]
        }, status: :ok
      end
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

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

  private

  def verify_recaptcha(recaptcha_token)
    # Implementation depends on the specific recaptcha service used
  end
end
