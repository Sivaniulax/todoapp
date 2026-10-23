require_relative "boot"

require "rails"
# Only the frameworks an API needs.
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"

Bundler.require(*Rails.groups)

module TodoApi
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    # API-only: no views or asset pipeline.
    config.api_only = true

    # Devise signs people in with a session cookie, and an API-only stack
    # leaves both of these out by default. Devise appends Warden to the end
    # of the stack, so they have to go in ahead of it or there is no session
    # for Warden to read.
    config.middleware.insert_before Warden::Manager, ActionDispatch::Cookies
    # SameSite=Lax is what stands in for CSRF tokens here: the browser will
    # not attach the cookie to a cross-site POST/PATCH/DELETE at all, and
    # every GET is read-only. Serving the app and the API from one domain
    # keeps it that way - see the deploy notes in the README.
    config.middleware.insert_before Warden::Manager, ActionDispatch::Session::CookieStore,
                                    key: "_todoapp_session",
                                    same_site: ENV.fetch("SESSION_COOKIE_SAME_SITE", "lax").to_sym,
                                    secure: Rails.env.production?

    # Decides what "today" means for due dates / overdue todos.
    config.time_zone = ENV.fetch("TIME_ZONE", "UTC")

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
