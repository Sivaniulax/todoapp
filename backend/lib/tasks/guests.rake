namespace :guests do
  desc "Delete guest accounts whose session has expired"
  task cleanup: :environment do
    count = CleanupExpiredGuestsJob.perform_now
    puts "Removed #{count} expired guest account(s)"
  end
end
