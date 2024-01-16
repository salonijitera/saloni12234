require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  
  # Existing user-related routes
  post '/api/users/login', to: 'api/users#login'
  post '/api/users/reset-password-request', to: 'users#reset_password_request'
  
  # New user-related route
  namespace :api do
    post '/users/verify-email', to: 'users#verify_email'
  end
  
  # ... other routes ...
end
