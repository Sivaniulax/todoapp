Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true
  config.cache_store = :null_store
  config.action_dispatch.show_exceptions = :rescuable
  config.active_support.deprecation = :stderr
  config.active_job.queue_adapter = :test
  config.action_controller.raise_on_missing_callback_actions = true
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "www.example.com" }
  config.action_mailer.preview_paths = [ Rails.root.join("spec/mailers/previews").to_s ]
end
