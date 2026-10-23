# Emails everyone who has todos due today. Scheduled from config/recurring.yml.
class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    sent = 0

    User.registered.find_each do |user|
      next if user.todos.kept.due_today.none?

      TodoMailer.daily_digest(user).deliver_later
      sent += 1
    end

    Rails.logger.info("[DailyDigestJob] queued #{sent} digest email(s)")
    sent
  end
end
