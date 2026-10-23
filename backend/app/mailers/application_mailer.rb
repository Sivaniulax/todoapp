class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "TodoApp <no-reply@todoapp.dev>")
  layout "mailer"

  private

  # The React app lives on another origin, so links point at the first
  # configured frontend URL rather than at this API.
  def frontend_url
    ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173").split(",").first.strip
  end
  helper_method :frontend_url
end
