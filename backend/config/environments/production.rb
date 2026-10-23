require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # Render terminates SSL in front of the app.
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  config.cache_store = :memory_store
  config.active_job.queue_adapter = :solid_queue

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # SMTP is optional: with no MAIL_SMTP_ADDRESS set, mail is simply not sent
  # and a failed delivery never takes a request down with it.
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = ENV["MAIL_SMTP_ADDRESS"].present?
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost") }
  config.action_mailer.smtp_settings = {
    address: ENV["MAIL_SMTP_ADDRESS"],
    port: ENV.fetch("MAIL_SMTP_PORT", 587).to_i,
    user_name: ENV["MAIL_SMTP_USERNAME"],
    password: ENV["MAIL_SMTP_PASSWORD"],
    authentication: :plain,
    enable_starttls_auto: true
  }
end
