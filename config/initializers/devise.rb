Devise.setup do |config|
  require 'devise/orm/active_record'

  config.secret_key = '11200e6b71f8e8fde943673fa4eb3ea60a3a63268f32ea7f7003d5c90d6ce37d18dde0613b66cc9a73bd6a24d705433018eed77ba225e42f54625a268dfc02b7'
  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end
