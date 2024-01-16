require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing user-related routes
  post '/api/users/login', to: 'api/users#login'
  
  # New user-related route from new code
  post '/api/users/register' => 'users#register'

  # New user-related route from existing code
  namespace :api do
    post '/users/verify-email', to: 'users#verify_email'
  end

  # Resolved conflict: The new route is already defined in the existing code, so we keep the existing namespace and path
  post '/api/users/reset-password-request', to: 'users#reset_password_request'
  
  # ... other routes ...
end
