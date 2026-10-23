# Only the settings this app changes. Everything else is Devise's default,
# which `rails generate devise:install` would have written out in full.
Devise.setup do |config|
  config.mailer_sender = ENV.fetch("MAIL_FROM", "TodoApp <no-reply@todoapp.dev>")

  require "devise/orm/active_record"

  # There are no HTML pages here, so Devise never redirects: a failed
  # authentication returns 401 JSON instead.
  config.navigational_formats = []

  # Matches the validations the API documented before Devise arrived.
  config.password_length = 8..72
  config.email_regexp = URI::MailTo::EMAIL_REGEXP

  # Sessions used to be 24h JWTs, so keep that lifetime.
  config.timeout_in = 24.hours

  # The client sends JSON, not form posts.
  config.sign_out_via = :delete
  config.responder.error_status = :unprocessable_entity
end
