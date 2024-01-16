if @user.persisted?
  json.status 201
  json.message "User registered successfully."
  json.id @user.id
else
  json.error @error_message
end
