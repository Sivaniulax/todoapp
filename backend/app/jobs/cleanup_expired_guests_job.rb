# Removes guest accounts, and their todos, once they expire. Enqueued whenever
# a new guest signs up, and runnable by hand with `bin/rails guests:cleanup`.
class CleanupExpiredGuestsJob < ApplicationJob
  queue_as :default

  def perform
    count = 0
    User.expired_guests.find_each do |guest|
      guest.destroy
      count += 1
    end
    Rails.logger.info("[CleanupExpiredGuestsJob] removed #{count} expired guest(s)")
    count
  end
end
