# Allow the React app to call this API from another origin.
# FRONTEND_ORIGINS is a comma-separated list, e.g.
#   "http://localhost:5173,https://todoapp.vercel.app"
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173").split(",").map(&:strip))

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end
