require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # rate_limit needs a real cache store.
  config.cache_store = :memory_store

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true
  # Solid Queue needs a forking supervisor, which Windows lacks, so development
  # runs jobs in-process. Production uses :solid_queue - see production.rb.
  config.active_job.queue_adapter = :async
  config.action_controller.raise_on_missing_callback_actions = true

  # Mail is never actually delivered in development - read it at /rails/mailers.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.preview_paths = [ Rails.root.join("spec/mailers/previews").to_s ]

  # Bullet complains about N+1 queries in the log. There is no browser here
  # to put a footer in.
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.raise = false
  end
end
