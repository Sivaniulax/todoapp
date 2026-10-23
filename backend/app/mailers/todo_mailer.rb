class TodoMailer < ApplicationMailer
  # Everything due today, sent by DailyDigestJob. Nothing due, nothing sent.
  def daily_digest(user)
    @user = user
    @todos = user.todos.kept.due_today.includes(:category).order(:priority)
    return if @todos.empty?

    mail to: @user.email, subject: t("mailers.todo_mailer.daily_digest.subject", count: @todos.size)
  end
end
