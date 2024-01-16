json.status @status
json.message @message

if @access_token.present?
  json.access_token @access_token
end
