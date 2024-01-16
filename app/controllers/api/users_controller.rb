module Api
  class UsersController < ApplicationController
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

    # POST /api/users/register
    def register
      result = UserService.register_user(
        email: user_params[:email],
        password: user_params[:password],
        password_confirmation: user_params[:password]
      )

      if result[:user_id]
        render json: { status: 201, message: result[:message] }, status: :created
      else
        case result[:error]
        when 'Invalid email format'
          render json: { error: result[:error] }, status: :unprocessable_entity
        when 'Email already registered'
          render json: { error: result[:error] }, status: :conflict
        when 'Password must be at least 8 characters long.'
          render json: { error: result[:error] }, status: :bad_request
        else
          render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
        end
      end
    end

    # POST /api/users/reset-password-request
    def reset_password_request
      begin
        result = Services::PasswordResetService.request_password_reset(params[:email])
        if result[:message]
          render json: { status: 200, message: "Password reset link sent to email." }, status: :ok
        else
          render json: { status: 404, message: "Email not found." }, status: :not_found
        end
      rescue ArgumentError => e
        render json: { status: 422, message: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Password reset error: #{e.message}"
        render json: { status: 500, message: e.message }, status: :internal_server_error
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

    def verify_email
      begin
        token = params.require(:token)
        result = EmailVerificationService.verify(token)
        render json: { status: 200, message: result[:message] }, status: :ok
      rescue VerificationTokenNotFound
        render json: { message: 'Invalid or expired token.' }, status: :not_found
      rescue VerificationTokenInvalid
        render json: { message: 'Invalid or expired token.' }, status: :unprocessable_entity
      rescue ActionController::ParameterMissing
        render json: { message: 'Token is required.' }, status: :bad_request
      rescue StandardError => e
        logger.error "Internal Server Error: #{e.message}"
        render json: { message: 'An unexpected error occurred on the server.' }, status: :internal_server_error
      end
    end

    private

    def user_params
      params.permit(:email, :password, :token)
    end

    def verify_recaptcha(recaptcha_token)
      # Implementation depends on the specific recaptcha service used
    end
  end
end
