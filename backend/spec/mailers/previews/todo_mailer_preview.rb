class TodoMailerPreview < ActionMailer::Preview
  def daily_digest
    user = Todo.due_today.first&.user || User.first
    TodoMailer.daily_digest(user)
  end
end
