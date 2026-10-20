require_relative "boot"

require "rails"
# Only the frameworks an API needs.
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module TodoApi
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    # API-only: no views, cookies, sessions or asset pipeline.
    config.api_only = true

    # Decides what "today" means for due dates / overdue todos.
    config.time_zone = ENV.fetch("TIME_ZONE", "UTC")

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
