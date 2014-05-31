if Rails.version > '4.1.0'
  Rails.application.config.action_dispatch.cookies_serializer = :json
end
